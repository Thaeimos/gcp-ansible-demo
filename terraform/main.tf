resource "google_project_service" "project" {
  for_each = toset(local.apis)
  project  = var.project
  service  = each.key
}

data "google_project" "project" {}
data "google_storage_project_service_account" "gcs_account" {}
data "google_client_openid_userinfo" "me" {}

# Network
data "google_compute_zones" "available" {}

resource "google_compute_network" "vpc_network" {
  name                    = "vpc-${var.project}"
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

resource "google_compute_firewall" "allow_ssh" {
  name          = "allow-ssh"
  network       = google_compute_network.vpc_network.name
  target_tags   = ["allow-ssh"]
  source_ranges = ["0.0.0.0/0"] # TODO Whitelist my IP

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

data "google_compute_image" "my_image" {
  family  = "fedora-cloud-39"
  project = "fedora-cloud"
}

resource "google_compute_instance" "ansible" {
  for_each = toset(data.google_compute_zones.available.names)

  name         = "vm-ansible-${random_id.suffix.hex}-${each.key}"
  machine_type = "e2-small"
  zone         = each.key

  boot_disk {
    initialize_params {
      image = data.google_compute_image.my_image.self_link
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.default[each.key].self_link

    access_config {
      network_tier = "STANDARD"
    }
  }

  allow_stopping_for_update = true

  metadata = {
    ssh-keys       = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.ssh.public_key_openssh}"
    startup-script = <<EOF
#!/bin/bash 
command -v cloud-init &>/dev/null || (dnf install -y cloud-init && reboot) 
EOF
    user-data      = <<EOT
#cloud-config# Create a group
groups:
  - ansible

# Create users, in addition to the users provided by default
users:
  - default
  - name: ansible
    shell: /bin/bash
    primary_group: ansible
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    lock_passwd: false
    ssh_authorized_keys:
      - "${tls_private_key.ssh.public_key_openssh}"

# to connect to this account# Run a few commands (update apt's repo indexes and install curl)
runcmd:
  - sudo apt-get update
  - sudo apt install curl -q -y
  - echo "Done"
EOT
  }

  tags = ["allow-ssh"]
  labels = merge(local.tags,
    {
      usage = "ansible"
    }
  )
}