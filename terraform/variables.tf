# Email ACME được truyền vào bootstrap.sh khi tạo ClusterIssuer Let's Encrypt.
variable "admin_email" {
  description = "Email nhận thông báo gia hạn SSL Let's Encrypt"
  type        = string
}
