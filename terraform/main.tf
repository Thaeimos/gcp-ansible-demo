resource "google_project_service" "project" {
    for_each = toset(local.apis)
    project = var.project
    service = each.key
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
    count = length(data.google_compute_zones.available.names)

    name          = "subnet-${data.google_compute_zones.available.names[count.index]}"
    ip_cidr_range = cidrsubnet(var.subnet_cidr, 8, count.index)
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
  filename        = "./ssh-private-key.secrets"
  file_permission = "0400"
}

resource "google_compute_instance" "ansible" {
    count = length(data.google_compute_zones.available.names)

    name         = "vm-ansible-${random_id.suffix.hex}-${count.index}"
    machine_type = "f1-micro"
    zone         = data.google_compute_zones.available.names[count.index]

    boot_disk {
        initialize_params {
        image = "debian-cloud/debian-9"
        }
    }

    network_interface {
        network = "default"

        access_config {
        }
    }

    metadata = {
        ssh-keys = "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.ssh.public_key_openssh}"
    }

    metadata_startup_script = "sudo apt-get update && sudo apt-get install apache2 -y && echo '<!doctype html><html><body><h1>Avenue Code is the leading software consulting agency focused on delivering end-to-end development solutions for digital transformation across every vertical. We pride ourselves on our technical acumen, our collaborative problem-solving ability, and the warm professionalism of our teams.!</h1></body></html>' | sudo tee /var/www/html/index.html"

    labels = merge(local.tags, 
        {
            usage = "ansible"
        }
    )
}