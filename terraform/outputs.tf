# Các output chỉ hiển thị thông tin sau apply; chúng không tạo tài nguyên mới.
output "vps_public_ip" {
  description = "Địa chỉ IP Public của VPS Oracle"
  value       = oci_core_instance.vps_full.public_ip
}

output "argocd_url" {
  # URL này được ghép từ IP; muốn truy cập được vẫn cần DNS, Ingress và TLS hoạt động.
  description = "Địa chỉ Web UI của ArgoCD"
  value       = "https://argocd.${oci_core_instance.vps_full.public_ip}.nip.io"
}
