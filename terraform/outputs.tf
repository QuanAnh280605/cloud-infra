output "vps_public_ip" {
  description = "Địa chỉ IP Public của VPS Oracle"
  value       = oci_core_instance.vps_full.public_ip
}

output "vps_shape" {
  description = "Cấu hình phần cứng VPS"
  value       = "${oci_core_instance.vps_full.shape} (${oci_core_instance.vps_full.shape_config[0].ocpus} OCPU, ${oci_core_instance.vps_full.shape_config[0].memory_in_gbs} GB RAM)"
}

output "ssh_command" {
  description = "Lệnh SSH đăng nhập vào VPS"
  value       = "ssh ubuntu@${oci_core_instance.vps_full.public_ip}"
}
