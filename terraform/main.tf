data "google_client_openid_userinfo" "me" {}

# resource "google_compute_network" "vpc_network" {
#   name = "terraform-network"
# }

# Network
data "google_compute_zones" "available" {}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network-${var.project}"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  for_each = { for idx, cidr_block in data.google_compute_zones.available.names : cidr_block => idx }

  name          = "subnet-${each.key}"
  ip_cidr_range = cidrsubnet(var.subnet_cidr, 8, each.value)
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Create ansible instances
resource "random_id" "suffix" {
  byte_length = 8
}


# Whitelist only my IP
data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}


resource "google_compute_firewall" "ssh-all" {
  name    = "ssh-all-terraform"
  network = google_compute_network.vpc_network.name

  target_tags = ["dev"]
  # source_ranges = ["${chomp(data.http.myip.response_body)}/32"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "http-web" {
  name    = "http-web-terraform"
  network = google_compute_network.vpc_network.name

  target_tags   = ["web"]
  source_ranges = ["${chomp(data.http.myip.response_body)}/32"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "node-api" {
  name    = "node-api-terraform"
  network = google_compute_network.vpc_network.name

  target_tags = ["api"]
  # source_tags = ["web"]
  # source_ranges = [var.subnet_cidr]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["3001"]
  }
}

# SSH
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = local.ssh_file_name
  file_permission = "0400"
}
