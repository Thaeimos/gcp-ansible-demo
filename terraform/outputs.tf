output "ssh_command_connect" {
    value = "ssh -i ${local.ssh_file_name} ansible@" #${google_compute_instance.ansible.*}"
}
