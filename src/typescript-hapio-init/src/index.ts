import axios, { AxiosInstance } from "axios";
import type {
  CreateResourceRequest,
  CreateServiceRequest,
  CreateLocationRequest,
  CreateResourceRespoonse,
  CreateServiceResponse,
  CreateLocationResponse,
  AttachServiceToResourceResponse,
  AttachServiceToResourceRequest,
  CreateRecurringScheduleRequest,
  CreateRecurringScheduleResponse,
  CreateRecurringScheduleBlockRequest,
  CreateRecurringScheduleBlockResponse,
} from "./types";

// Add your Hapio access token here
const hapio_access_token = "";

const createHapioClient = () => {
  return axios.create({
    baseURL: "https://eu-central-1.hapio.net/v1/",
    headers: {
      Authorization: `Bearer ${hapio_access_token}`,
    },
    validateStatus: () => {
      return true;
    },
  });
};

const createResource = async (
  client: AxiosInstance,
  body: CreateResourceRequest
) => {
  console.log("Creating resource with body:", body);
  const response = await client.post("resources", body);

  if (response.status !== 201) {
    console.error(
      "There is an error processing on creating resource",
      response.data
    );
    throw new Error(`Failed to create resource: ${response.status}`);
  }

  return response.data as CreateResourceRespoonse;
};

const createService = async (
  client: AxiosInstance,
  body: CreateServiceRequest
) => {
  console.log("Creating service with body:", body);
  const response = await client.post("services", body);

  if (response.status !== 201) {
    console.error(
      "There is an error processing on creating service",
      response.data
    );
    throw new Error(`Failed to create service: ${response.status}`);
  }

  return response.data as CreateServiceResponse;
};

const createLocation = async (
  client: AxiosInstance,
  body: CreateLocationRequest
) => {
  console.log("Creating location with body:", body);
  const response = await client.post("locations", body);

  if (response.status !== 201) {
    console.error(
      "There is an error processing on creating location",
      response.data
    );
    throw new Error(`Failed to create location: ${response.status}`);
  }

  return response.data as CreateLocationResponse;
};

const attachServiceToResource = async (
  client: AxiosInstance,
  request: AttachServiceToResourceRequest
) => {
  console.log("Attaching service to resource...");
  const response = await client.put(
    `services/${request.service_id}/resources/${request.resource_id}`,
    {}
  );

  if (response.status !== 201) {
    console.error(
      "There is an error processing on attaching service to resource",
      response.data
    );
    throw new Error(`Failed to attach service to resource: ${response.status}`);
  }

  return response.data as AttachServiceToResourceResponse;
};

const createRecurringSchedule = async (
  client: AxiosInstance,
  resource_id: string,
  request: CreateRecurringScheduleRequest
) => {
  console.log("Creating recurring schedule with body:", request);
  const response = await client.post(
    `resources/${resource_id}/recurring-schedules`,
    request
  );

  if (response.status !== 201) {
    console.error(
      "There is an error processing on creating recurring schedule",
      response.data
    );
    throw new Error(`Failed to create recurring schedule: ${response.status}`);
  }

  return response.data as CreateRecurringScheduleResponse;
};

const createRecurringScheduleBlock = async (
  client: AxiosInstance,
  resource_id: string,
  recurring_schedule_id: string,
  request: CreateRecurringScheduleBlockRequest
) => {
  console.log("Creating recurring schedule block with body:", request);
  const response = await client.post(
    `resources/${resource_id}/recurring-schedules/${recurring_schedule_id}/schedule-blocks`,
    request
  );

  if (response.status !== 201) {
    console.error(
      "There is an error processing on creating recurring schedule block",
      response.data
    );
    throw new Error(
      `Failed to create recurring schedule block: ${response.status}`
    );
  }

  return response.data as CreateRecurringScheduleBlockResponse;
};

// Main function to perform the operations
const performOperations = async () => {
  const client = createHapioClient();

  const resource = await createResource(client, {
    name: "Test Agent",
    max_simultaneous_bookings: 1,
    enabled: true,
  });
  console.log("Created resource:", resource.id);

  const service = await createService(client, {
    name: "Test Service",
    type: "fixed",
    price: null,
    duration: "PT50M",
    bookable_interval: "PT1H",
    buffer_time_before: "PT0S",
    buffer_time_after: "PT10M",
    booking_window_start: "PT2H",
    booking_window_end: "P14D",
    cancelation_threshold: "PT12H",
    metadata: null,
    protected_metadata: null,
    enabled: true,
  });
  console.log("Created service:", service.id);

  const location = await createLocation(client, {
    name: "Test Location",
    time_zone: "America/New_York",
    resource_selection_strategy: "equalize",
    enabled: true,
  });
  console.log("Created location:", location.id);

  const attachServiceToResourceResponse = await attachServiceToResource(
    client,
    {
      service_id: service.id ?? "",
      resource_id: resource.id ?? "",
    }
  );
  console.log("Resource attached to service...");

  const recurringSchedule = await createRecurringSchedule(
    client,
    resource.id ?? "",
    {
      location_id: location.id ?? "",
      start_date: new Date().toISOString().split("T")[0],
      end_date: null,
      interval: 1,
    }
  );
  console.log("Created recurring schedule:", recurringSchedule.id);

  const daysOfWeek = ["monday", "tuesday", "wednesday", "thursday", "friday"];
  for (const day of daysOfWeek) {
    await createRecurringScheduleBlock(
      client,
      resource.id ?? "",
      recurringSchedule.id ?? "",
      {
        weekday: day as
          | "monday"
          | "tuesday"
          | "wednesday"
          | "thursday"
          | "friday"
          | "saturday"
          | "sunday",
        start_time: "09:00:00",
        end_time: "18:00:00",
      }
    );
    console.log(`Created recurring schedule block for ${day}`);
  }

  console.log("All operations completed successfully.");
  console.log("Resource ID:", resource.id);
  console.log("Service ID:", service.id);
  console.log("Location ID:", location.id);
};

performOperations();
