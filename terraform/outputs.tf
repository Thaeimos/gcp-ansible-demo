output "ssh_command_connect" {
  value = toset([
    for vm in google_compute_instance.ansible :
    "ssh -i ${local.ssh_file_name} ${split("@", data.google_client_openid_userinfo.me.email)[0]}@${vm.network_interface[0].access_config[0].nat_ip}"
  ])
}
