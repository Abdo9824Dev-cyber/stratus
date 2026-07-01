variable "project_id" {
  type        = string
  description = "The GCP Project ID where resources will be deployed."
}

variable "region" {
  type        = string
  description = "The target GCP region for the infrastructure (e.g., europe-west3)."
}

variable "network_id" {
  type        = string
  description = "The ID of the VPC network, outputted from the network module."
}

variable "subnet_id" {
  type        = string
  description = "The ID of the specific private subnet where the application tier resides."
}

variable "image" {
  type        = string
  description = "The full URL path to the container image in Artifact Registry."
}

variable "db_host" {
  type        = string
  description = "The private IP address of the Cloud SQL database instance."
}

variable "db_name" {
  type        = string
  description = "The name of the specific database to connect to."
}

variable "db_user" {
  type        = string
  description = "The database username for application authentication."
}

variable "password_secret_id" {
  type        = string
  description = "The resource ID or name of the database password stored in Secret Manager."
}

variable "repo_id" {
  type        = string
  default     = "stratus"
  description = "The repository identifier used for tracking or naming conventions."
}