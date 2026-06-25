# ==============================================================================
# 1. VIRTUAL PRIVATE CLOUD (VPC)
# ==============================================================================
resource "google_compute_network" "vpc" {
  name                    = var.network_name
  project                 = var.project_id
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false # Custom-mode VPC
}

# ==============================================================================
# 2. SUBNETS
# ==============================================================================
resource "google_compute_subnetwork" "public" {
  name          = "${var.network_name}-public"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.public_subnet_cidr
}

resource "google_compute_subnetwork" "private" {
  name                     = "${var.network_name}-private"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = var.private_subnet_cidr
  private_ip_google_access = true # Allows reaching Google APIs without external IPs
}

# ==============================================================================
# 3. ROUTER & NAT (Gated behind the enable_nat switch)
# ==============================================================================
resource "google_compute_router" "router" {
  count   = var.enable_nat ? 1 : 0
  name    = "${var.network_name}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  count                              = var.enable_nat ? 1 : 0
  name                               = "${var.network_name}-nat"
  project                            = var.project_id
  region                             = var.region
  router                             = google_compute_router.router[0].name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# ==============================================================================
# 4. FIREWALL RULES
# ==============================================================================
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  project = var.project_id
  network = google_compute_network.vpc.id

  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }

  source_ranges = [var.public_subnet_cidr, var.private_subnet_cidr]
}

resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.network_name}-allow-iap-ssh"
  project = var.project_id
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] # Strict Google IAP CIDR range
}