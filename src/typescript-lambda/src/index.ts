import axios from "axios";
import { DateTime } from "luxon";
import config from "./config";
import type {
  Event,
  CreateBookingEventRequest,
  CreateBookingRawRequest,
  CreateBookingRawResponse,
  GetBookableSlotsEventRequest,
  GetBookableSlotsRawRequestParams,
  GetBookableSlotsRawResponse,
  GetBookableSlotsEventResponse,
  GetLocationDetailsRawResponse,
  CreateBookingEventResponse,
} from "./types/index";

exports.handler = async (event: Event) => {
  console.log("Event:", JSON.stringify(event, null, 2));

  switch (event.type) {
    case "getBookableSlots":
      return await getBookableSlots(event.body as GetBookableSlotsEventRequest);
    case "createBooking":
      return await createBooking(event.body as CreateBookingEventRequest);
    default:
      throw new Error(`Unknown event type: ${event.type}`);
  }
};

const createHapioClient = () => {
  return axios.create({
    baseURL: "https://eu-central-1.hapio.net/v1/",
    headers: {
      Authorization: `Bearer ${config.hapio_access_token}`,
    },
  });
};

const getBookableSlots = async (request: GetBookableSlotsEventRequest) => {
  const client = createHapioClient();
  const locationTimezone = (await getLocationDetails(config.hapio_location_id))
    .time_zone;
  const timezoneOffset = DateTime.now()
    .setZone(locationTimezone)
    .toFormat("ZZ");

  const queryParams = {
    from: `${request.date}T00:00:00${timezoneOffset}`,
    to: `${request.date}T23:59:59${timezoneOffset}`,
    location: config.hapio_location_id,
  } satisfies GetBookableSlotsRawRequestParams;

  const response = await client.get(
    `services/${config.hapio_service_id}/bookable-slots`,
    {
      params: queryParams,
    }
  );

  if (response.status !== 200) {
    throw new Error(`Failed to get bookable slots: ${response.status}`);
  }

  console.log("GetBookableSlots response:", response.data);
  const parsedResponse = processBookableSlotsResponse(
    response.data as GetBookableSlotsRawResponse,
    locationTimezone
  );
  console.log("Parsed GetBookableSlots response:", parsedResponse);
  return parsedResponse;
};

const processBookableSlotsResponse = (
  responseData: GetBookableSlotsRawResponse,
  timezone: string = "UTC"
): GetBookableSlotsEventResponse => {
  let time: string[] = [];
  let time_complete: string[] = [];
  let start_time: string[] = [];
  let end_time: string[] = [];

  responseData.data?.forEach((slot) => {
    time.push(
      DateTime.fromISO(slot.starts_at!).setZone(timezone).toFormat("t")
    );
    time_complete.push(
      DateTime.fromISO(slot.buffer_starts_at!)
        .setZone(timezone)
        .toFormat("TT.SSS") ?? ""
    );
    start_time.push(slot.starts_at ?? "");
    end_time.push(slot.ends_at ?? "");
  });
  return {
    time,
    time_complete,
    start_time,
    end_time,
  };
};

const createBooking = async (
  request: CreateBookingEventRequest
): Promise<CreateBookingEventResponse> => {
  const client = createHapioClient();

  const requestBody = {
    service_id: config.hapio_service_id,
    location_id: config.hapio_location_id,
    starts_at: request.start_time,
    ends_at: request.end_time,
    is_temporary: false,
    ignore_schedule: false,
    ignore_fully_booked: false,
    ignore_bookable_slots: false,
    ignore_booking_window: false,
  } satisfies CreateBookingRawRequest;

  const response = await client.post("bookings", requestBody);

  if (response.status !== 201) {
    throw new Error(`Failed to create booking: ${response.status}`);
  }
  const responseBody: CreateBookingRawResponse = response.data;
  console.log("CreateBooking response:", responseBody);
  return { id: responseBody.id ?? "" };
};

const getLocationDetails = async (
  locationId: string
): Promise<GetLocationDetailsRawResponse> => {
  const client = createHapioClient();

  const response = await client.get(`locations/${locationId}`);

  if (response.status !== 200) {
    throw new Error(`Failed to get location details: ${response.status}`);
  }

  return response.data as GetLocationDetailsRawResponse;
};
