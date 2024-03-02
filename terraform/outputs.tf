output "ssh_command_connect_api" {
  value = toset([
    for vm in google_compute_instance.vm_api_instance :
    "ssh -i ${local.ssh_file_name} ${split("@", data.google_client_openid_userinfo.me.email)[0]}@${vm.network_interface[0].access_config[0].nat_ip}"
  ])
}

# output "ssh_command_connect_web" {
#   value = toset([
#     for vm in google_compute_instance.vm_web_instance :
#     "ssh -i ${local.ssh_file_name} ${split("@", data.google_client_openid_userinfo.me.email)[0]}@${vm.network_interface[0].access_config[0].nat_ip}"
#   ])
# }

# output "ssh_command_connect_db" {
#   value = toset([
#     for vm in google_compute_instance.vm_db_instance :
#     "ssh -i ${local.ssh_file_name} ${split("@", data.google_client_openid_userinfo.me.email)[0]}@${vm.network_interface[0].access_config[0].nat_ip}"
#   ])
# }
