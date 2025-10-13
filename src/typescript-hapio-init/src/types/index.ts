import type { components, operations } from "./hapio-api";

// Resource
type CreateResourceRequest = components["schemas"]["Resource"];

type CreateResourceRespoonse =
  operations["postResource"]["responses"]["201"]["content"]["application/json"];

// Service
type CreateServiceRequest = components["schemas"]["Service"];

type CreateServiceResponse =
  operations["postService"]["responses"]["201"]["content"]["application/json"];

// Location
type CreateLocationRequest = components["schemas"]["Location"];

type CreateLocationResponse =
  operations["postLocation"]["responses"]["201"]["content"]["application/json"];

// Attach Service to Resource
type AttachServiceToResourceRequest = components["schemas"]["ResourceService"];

type AttachServiceToResourceResponse =
  operations["putServiceResource"]["responses"]["201"]["content"]["application/json"];

// Create Recurring Schedule
type CreateRecurringScheduleRequest =
  components["schemas"]["RecurringSchedule"];

type CreateRecurringScheduleResponse =
  operations["postResourceRecurringSchedule"]["responses"]["201"]["content"]["application/json"];

// Create Recurring Schedule Block
type CreateRecurringScheduleBlockRequest =
  components["schemas"]["RecurringScheduleBlock"];

type CreateRecurringScheduleBlockResponse =
  operations["postResourceRecurringScheduleBlock"]["responses"]["201"]["content"]["application/json"];

export {
  CreateResourceRequest,
  CreateResourceRespoonse,
  CreateServiceRequest,
  CreateServiceResponse,
  CreateLocationRequest,
  CreateLocationResponse,
  AttachServiceToResourceRequest,
  AttachServiceToResourceResponse,
  CreateRecurringScheduleRequest,
  CreateRecurringScheduleResponse,
  CreateRecurringScheduleBlockRequest,
  CreateRecurringScheduleBlockResponse,
};
