variable "project_id" {
  type        = string
  description = "The GCP project ID where the resources will be deployed."
}

variable "region" {
  type        = string
  description = "The target Google Cloud region for the resources."
}

variable "network_id" {
  type        = string
  description = "The ID/self_link of the VPC network, passed from the network module."
}

variable "db_version" {
  type        = string
  default     = "POSTGRES_16"
  description = "The database engine version to use for Cloud SQL."
}

variable "db_name" {
  type        = string
  default     = "store"
  description = "The name of the default database to create."
}

variable "db_user" {
  type        = string
  default     = "store"
  description = "The username for the initial database user."
}

variable "db_tier" {
  type        = string
  default     = "db-f1-micro"
  description = "Cost-safe default tier (shared-core, cheapest) for standalone development."
}

variable "ha_tier" {
  type        = string
  default     = "db-custom-1-3840"
  description = "HA-capable machine tier; used only when enable_ha is true."
}

variable "enable_ha" {
  type        = bool
  default     = false
  description = "High Availability toggle switch. Set to true only for production/showcase environments."
}