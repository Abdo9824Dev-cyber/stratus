output "instance_name" {
  value       = google_sql_database_instance.main.name
  description = "The dynamically generated name of the Cloud SQL instance (includes the random hex suffix)."
}

output "instance_connection_name" {
  value       = google_sql_database_instance.main.connection_name
  description = "The connection string used by Cloud Run or the Cloud SQL Proxy (format: project:region:instance)."
}

output "private_ip" {
  value       = google_sql_database_instance.main.private_ip_address
  description = "The private IP address assigned to the instance within the peered VPC network."
}

output "db_name" {
  value       = google_sql_database.app.name
  description = "The name of the default application database running inside the engine."
}

output "db_user" {
  value       = google_sql_user.app.name
  description = "The default database username required for authentication."
}

output "password_secret_id" {
  value       = google_secret_manager_secret.db_password.secret_id
  description = "The resource ID of the Secret Manager secret holding the database password."
}