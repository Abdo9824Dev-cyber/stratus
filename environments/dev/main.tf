# ==============================================================================
# 1. MODULE CALLS
# ==============================================================================
# This block instantiates the reusable network module and passes the environment's 
# specific configuration values into it.
module "network" {
  source     = "../../modules/network"
  project_id = var.project_id
  region     = var.region
  enable_nat = false # Cost-safe switch: keeps the only billable item completely off
}

# This block instantiates the reusable database module and connects it to your VPC network.
module "database" {
  source     = "../../modules/database"
  project_id = var.project_id
  region     = var.region
  network_id = module.network.network_id
  enable_ha  = false # cost-safe; showcase HA in Phase 7
}

# ==============================================================================
# 2. ENVIRONMENT OUTPUTS
# ==============================================================================
# These blocks surface key values from the modules up to the root level 
# for quick viewing in your terminal after running a 'terraform apply'.
output "vpc_name" {
  value       = module.network.network_name
  description = "The name of the VPC created in the dev environment."
}

output "private_subnet" {
  value       = module.network.private_subnet_name
  description = "The name of the private subnet created in the dev environment."
}

output "db_private_ip" {
  value       = module.database.private_ip
  description = "The private IP address of the database instance, surfaced to the root level."
}

output "db_connection_name" {
  value       = module.database.instance_connection_name
  description = "The database connection string, surfaced to the root level for application integration."
}