
output "public_ip" {
    value = "${oci_core_instance.personal_server_vm_instance.public_ip}"
}

output "public_key" {
  value = "${tls_private_key.public_private_key_pair.public_key_openssh}"
}
output "private_key" {
  value = "${tls_private_key.public_private_key_pair.private_key_pem}"
}

output "local_ad" {
  value = "${local.ad_1}"
}