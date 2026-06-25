variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "network_name" {
    type = string
    default = "stratus-vpc"
}

variable "public_subnet_cidr" {
    type = string
    default = "10.10.0.0/24"
}

variable "private_subnet_cidr" {
    type = string
    default = "10.20.0.0/24"
}

# Cost-safe switch: Cloud NAT (the only billable item here) stays OFF
variable "enable_nat" {
  type = bool
  default = false
}