# ==============================================================================
# STRATUS APPLICATION TIER INFRASTRUCTURE
# ==============================================================================

# Container registry to store the application artifacts
resource "google_artifact_registry_repository" "app" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repo_id
  format        = "DOCKER"

  description   = "Docker repository for Stratus application container images"
}

# Least-privilege service account for the Cloud Run service execution
resource "google_service_account" "run" {
  project      = var.project_id
  account_id   = "stratus-run"
  display_name = "Stratus Cloud Run Service Account"
}

# Authorize the service account to read ONLY the specific DB password secret
resource "google_secret_manager_secret_iam_member" "run_secret" {
  project   = var.project_id
  secret_id = var.password_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.run.email}"
}

# Provision the Cloud Run service with Direct VPC Egress
resource "google_cloud_run_v2_service" "app" {
  name     = "stratus-app"
  project  = var.project_id
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"
    deletion_protection = false 

  template {
    service_account = google_service_account.run.email

    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }

    # Direct VPC egress — reach the private DB directly through the subnet
    vpc_access {
      network_interfaces {
        network    = var.network_id
        subnetwork = var.subnet_id
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = var.image
      
      ports { 
        container_port = 8080 
      }

      # Expanded multi-line syntax to resolve syntax error
      env {
        name  = "DB_HOST"
        value = var.db_host
      }
      env {
        name  = "DB_PORT"
        value = "5432"
      }
      env {
        name  = "DB_NAME"
        value = var.db_name
      }
      env {
        name  = "DB_USER"
        value = var.db_user
      }
      
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = var.password_secret_id
            version = "latest"
          }
        }
      }
    }
  }
}

# Make the Cloud Run service publicly accessible
resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}