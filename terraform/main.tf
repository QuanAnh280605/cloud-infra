terraform {
  # OCI provider tạo và quản lý VPS; lock file cố định phiên bản cụ thể trong nhánh 7.x.
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.0"
    }
  }
}

provider "oci" {
  # SecurityToken dùng profile OCI CLI trên máy chạy Terraform, không phải quyền của Pod.
  auth                = "SecurityToken"
  config_file_profile = "quan"
  region              = "ap-singapore-2"
}

resource "oci_core_instance" "vps_full" {
  # Máy ARM một node trong compartment, AD và fault domain đã chọn.
  availability_domain = "ScQZ:AP-SINGAPORE-2-AD-1"
  compartment_id      = "ocid1.tenancy.oc1..aaaaaaaavms5zapkgqcrgb5nkp57u7rfnmvgkfuun7jrs7oi34pyvm5uehaa"
  display_name        = "instance-20261001-1134"
  fault_domain        = "FAULT-DOMAIN-3"

  # Public key được đưa vào VPS khi tạo máy; private key chỉ nằm trên máy quản trị.
  metadata = {
    ssh_authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDX9m1FmH/viHww64+u3UCuQklQok5ZNbysbl3oqDgpRgAaPNUe1ONlivMY3befP37tEK1IJTSAD1UeOw5xK/861OB/7ABxy5dm/d/mMRC4BEAFtqIRF4knzr1pwa3n3mnRCLvAOZVRQq+JSWXvD2DSNtG4zGpP3mAWHcThj+LVPXlhvOIIg/GDGctWK5tC9TwwHoE2Q1JRo48EoBaZbn+E3FYjbvMNbbuOKT9nsKuOV/FlnlUafKrTH+2E/t7hsT2sv9CZU6rMVf1jCn02F/52PFV/sgnI4rUvZWmqDf7powDropd8/Ashk/gpDmFdDAiOchcfQ2+VdjS/1nDeibLt ssh-key-2026-10-01"
  }
  shape = "VM.Standard.A1.Flex"
  state = "RUNNING"

  # Không ưu tiên live migration khi OCI bảo trì phần cứng.
  availability_config {
    is_live_migration_preferred = false
  }

  # VNIC nối VPS vào subnet hiện có và cấp IP công khai cho Ingress/SSH.
  create_vnic_details {
    assign_private_dns_record = false
    assign_public_ip          = "true"
    display_name              = "instance-20261001-1134"
    nsg_ids                   = []
    private_ip                = "10.0.0.204"
    subnet_id                 = "ocid1.subnet.oc1.ap-singapore-2.aaaaaaaazbppuzzgideqepnagevs5xbcbwfbvvvu3lskfaofdom3mlnydl7q"
  }

  # Chặn endpoint metadata đời cũ trên instance.
  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }
  # Cố định cách VM khởi động và nhìn thấy thiết bị mạng/ổ đĩa.
  launch_options {
    boot_volume_type                    = "PARAVIRTUALIZED"
    firmware                            = "UEFI_64"
    is_consistent_volume_naming_enabled = true
    is_pv_encryption_in_transit_enabled = true
    network_type                        = "PARAVIRTUALIZED"
    remote_data_volume_type             = "PARAVIRTUALIZED"
  }
  # Tài nguyên thực cấp cho shape A1 Flex.
  shape_config {
    memory_in_gbs = 12
    nvmes         = 0
    ocpus         = 2
    vcpus         = 2
  }
  # Tạo boot volume từ image OCI đã chọn.
  source_details {
    boot_volume_size_in_gbs         = "47"
    boot_volume_vpus_per_gb         = "10"
    is_preserve_boot_volume_enabled = false
    source_id                       = "ocid1.image.oc1.ap-singapore-2.aaaaaaaan7h2srks22b2jnihsx7i5vwdurk7g6wq5wtjmnzqaghiesnintxa"
    source_type                     = "image"
  }

  # Bỏ qua thay đổi metadata và tag sau khi tạo máy; quy tắc này không ngăn thay thế VPS.
  lifecycle {
    ignore_changes = [
      metadata,
      defined_tags,
      freeform_tags,
      create_vnic_details[0].defined_tags
    ]
  }
}



resource "terraform_data" "k3s_bootstrap" {
  # Chỉ chạy lại bootstrap khi ID VPS đổi; sửa bootstrap.sh không kích hoạt lại.
  triggers_replace = [
    oci_core_instance.vps_full.id
  ]
  # Terraform kết nối từ máy quản trị tới IP công khai của VPS.
  connection {
    type = "ssh"
    user = "ubuntu"
    host = oci_core_instance.vps_full.public_ip
    # pathexpand mở rộng ~ thành thư mục home của máy chạy Terraform.
    private_key = file(pathexpand("~/.ssh/oracle_vps.key"))
    timeout     = "3m"
  }
  # Chép script cục bộ lên /tmp của VPS trước khi chạy.
  provisioner "file" {
    source      = "${path.module}/script/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  # Cài các thành phần nền tảng rồi xóa bản script tạm trên VPS.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "/tmp/bootstrap.sh ${var.admin_email} '${oci_core_instance.vps_full.public_ip}'",
      "rm -f /tmp/bootstrap.sh"
    ]
  }
}
