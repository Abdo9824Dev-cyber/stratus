# ==============================================================================
# 1. MODULE CALL
# ==============================================================================
# This block instantiates the reusable network module and passes the environment's 
# specific configuration values into it.
module "network" {
  source     = "../../modules/network"
  project_id = var.project_id
  region     = var.region
  enable_nat = false # Cost-safe switch: keeps the only billable item completely off
}

# ==============================================================================
# 2. ENVIRONMENT OUTPUTS
# ==============================================================================
# These blocks surface key values from the network module up to the root level 
# for quick viewing in your terminal after running a 'terraform apply'.
output "vpc_name" {
  value       = module.network.network_name
  description = "The name of the VPC created in the dev environment."
}

output "private_subnet" {
  value       = module.network.private_subnet_name
  description = "The name of the private subnet created in the dev environment."
}