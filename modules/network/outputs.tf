output "network_id" { value = google_compute_network.vpc.id }
output "network_name" { value = google_compute_network.vpc.name }
output "private_subnet_id" { value = google_compute_subnetwork.private.id }
output "private_subnet_name" { value = google_compute_subnetwork.private.name }
output "public_subnet_id" { value = google_compute_subnetwork.public.id }
output "nat_enabled" { value = var.enable_nat }
