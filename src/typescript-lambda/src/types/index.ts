import type { components, operations } from "./hapio-api";

type Event = {
  type: "getBookableSlots" | "createBooking";
  body: GetBookableSlotsEventRequest | CreateBookingEventRequest;
};

type GetBookableSlotsEventRequest = {
  date: string;
};

type GetBookableSlotsRawRequestParams =
  operations["getServiceBookableSlots"]["parameters"]["query"];

type GetBookableSlotsRawResponse =
  operations["getServiceBookableSlots"]["responses"]["200"]["content"]["application/json"];

type GetBookableSlotsEventResponse = {
  time: string[];
  time_complete: string[];
  start_time: string[];
  end_time: string[];
};

type CreateBookingEventRequest = {
  start_time: string;
  end_time: string;
};

type CreateBookingRawRequest = components["schemas"]["BookingPost"];

type CreateBookingRawResponse =
  operations["postBooking"]["responses"]["201"]["content"]["application/json"];

type CreateBookingEventResponse = {
  id: string;
};

type GetLocationDetailsRawResponse =
  operations["getLocation"]["responses"]["200"]["content"]["application/json"];

export {
  Event,
  GetBookableSlotsEventRequest,
  GetBookableSlotsRawRequestParams,
  GetBookableSlotsRawResponse,
  GetBookableSlotsEventResponse,
  CreateBookingEventRequest,
  CreateBookingRawRequest,
  CreateBookingRawResponse,
  CreateBookingEventResponse,
  GetLocationDetailsRawResponse,
};
