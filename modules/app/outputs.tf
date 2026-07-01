output "url" { value = google_cloud_run_v2_service.app.uri }
output "repo" { value = google_artifact_registry_repository.app.name }
output "run_sa" { value = google_service_account.run.email }