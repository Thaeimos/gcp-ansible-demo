resource "google_compute_address" "vm_db_ip" {
  name = "db-ip"
}

resource "google_compute_instance" "vm_db_instance" {
  name         = "vm-db"
  machine_type = var.vm_type
  tags         = ["db", "dev"]
  zone         = lookup((data.google_compute_zones.available), "names")[0]

  boot_disk {
    initialize_params {
      # image = "ubuntu-1804-bionic-v20220308"
      image = data.google_compute_image.my_image.self_link
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.default[keys(google_compute_subnetwork.default)[0]].self_link
    access_config {
      nat_ip       = google_compute_address.vm_db_ip.address
      network_tier = "PREMIUM"
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
#cloud-config
# Create a group
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

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = local.sa_email
    scopes = ["cloud-platform"]
  }

  labels = merge(local.tags,
    {
      usage       = "ansible"
      tier        = "deb"
      environment = "dev"
    }
  )
}
