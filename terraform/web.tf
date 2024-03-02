resource "google_compute_address" "vm_web_ip" {
  name = "web-ip"
}

resource "google_compute_instance" "vm_web_instance" {
  name         = "vm-web"
  machine_type = "f1-micro"
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20220308"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.default[keys(google_compute_subnetwork.default)[0]].self_link
    access_config {
      nat_ip       = google_compute_address.vm_web_ip.address
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

  labels = merge(local.tags,
    {
      usage       = "ansible"
      tier        = "web"
      environment = "dev"
    }
  )
}
