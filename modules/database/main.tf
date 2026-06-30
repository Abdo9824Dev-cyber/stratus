# 1) Reserve an internal IP range for Google-managed services
resource "google_compute_global_address" "private_range" {
  name          = "stratus-sql-range"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_id
}

# 2) Peer the VPC with Service Networking using that range
resource "google_service_networking_connection" "private_vpc" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_range.name]
}

# A unique suffix so a destroyed instance name can be reused immediately
resource "random_id" "suffix" {
  byte_length = 2
}

# The DB password — generated, never hard-coded
resource "random_password" "db" {
  length  = 24
  special = false
}

# Secret Manager Secret envelope
resource "google_secret_manager_secret" "db_password" {
  project   = var.project_id
  secret_id = "stratus-db-password"

  replication {
    auto {}
  }
}

# Secret Manager Secret data version
resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db.result
}

resource "google_sql_database_instance" "main" {
  name                = "stratus-db-${random_id.suffix.hex}"
  project             = var.project_id
  region              = var.region
  database_version    = var.db_version
  deletion_protection = false # Learning project: let's destroy work cleanly

  # Ensures Private Services Access is fully set up before provisioning
  depends_on = [google_service_networking_connection.private_vpc]

  settings {
    tier              = var.enable_ha ? var.ha_tier : var.db_tier
    availability_type = var.enable_ha ? "REGIONAL" : "ZONAL" # REGIONAL = Multi-zone HA
    edition           = "ENTERPRISE"
    disk_size         = 10
    disk_type         = "PD_SSD"
    disk_autoresize   = false

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "03:00"
    }

    ip_configuration {
      ipv4_enabled    = false          # Disables public IP address entirely
      private_network = var.network_id # Force traffic over the private peering network
    }

    maintenance_window {
      day  = 7 # Sunday
      hour = 4
    }
  }
}

resource "google_sql_database" "app" {
  name     = var.db_name
  project  = var.project_id
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "app" {
  name     = var.db_user
  project  = var.project_id
  instance = google_sql_database_instance.main.name
  password = random_password.db.result
}




