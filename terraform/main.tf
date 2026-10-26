terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.0"
    }
  }
}

provider "oci" {
  auth                = "SecurityToken"
  config_file_profile = "quan"
  region              = "ap-singapore-2"
}

resource "oci_core_instance" "vps_full" {
  async                      = null
  availability_domain        = "ScQZ:AP-SINGAPORE-2-AD-1"
  cluster_placement_group_id = null
  compartment_id             = "ocid1.tenancy.oc1..aaaaaaaavms5zapkgqcrgb5nkp57u7rfnmvgkfuun7jrs7oi34pyvm5uehaa"
  defined_tags = {
    "Oracle-Tags.CreatedBy" = "default/quannguyenanh280605@gmail.com"
    "Oracle-Tags.CreatedOn" = "2026-10-01T04:35:07.000Z"
  }
  display_name      = "instance-20261001-1134"
  extended_metadata = {}
  fault_domain      = "FAULT-DOMAIN-3"
  freeform_tags     = {}
  metadata = {
    ssh_authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDX9m1FmH/viHww64+u3UCuQklQok5ZNbysbl3oqDgpRgAaPNUe1ONlivMY3befP37tEK1IJTSAD1UeOw5xK/861OB/7ABxy5dm/d/mMRC4BEAFtqIRF4knzr1pwa3n3mnRCLvAOZVRQq+JSWXvD2DSNtG4zGpP3mAWHcThj+LVPXlhvOIIg/GDGctWK5tC9TwwHoE2Q1JRo48EoBaZbn+E3FYjbvMNbbuOKT9nsKuOV/FlnlUafKrTH+2E/t7hsT2sv9CZU6rMVf1jCn02F/52PFV/sgnI4rUvZWmqDf7powDropd8/Ashk/gpDmFdDAiOchcfQ2+VdjS/1nDeibLt ssh-key-2026-10-01"
  }
  preserve_boot_volume                    = null
  preserve_data_volumes_created_at_launch = null
  security_attributes                     = {}
  shape                                   = "VM.Standard.A1.Flex"
  state                                   = "RUNNING"
  update_operation_constraint             = null
  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false
    plugins_config {
      desired_state = "DISABLED"
      name          = "Vulnerability Scanning"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "OS Management Hub Agent"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Management Agent"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Custom Logs Monitoring"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Compute RDMA GPU Monitoring"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Run Command"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Compute Instance Monitoring"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Compute HPC RDMA Auto-Configuration"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Compute HPC RDMA Authentication"
    }
    plugins_config {
      desired_state = "ENABLED"
      name          = "Cloud Guard Workload Protection"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Block Volume Management"
    }
    plugins_config {
      desired_state = "DISABLED"
      name          = "Bastion"
    }
  }
  availability_config {
    is_live_migration_preferred = false
    recovery_action             = "RESTORE_INSTANCE"
  }
  create_vnic_details {
    assign_ipv6ip             = false
    assign_private_dns_record = false
    assign_public_ip          = "true"
    defined_tags = {
      "Oracle-Tags.CreatedBy" = "default/quannguyenanh280605@gmail.com"
      "Oracle-Tags.CreatedOn" = "2026-10-01T04:35:07.068Z"
    }
    display_name           = "instance-20261001-1134"
    freeform_tags          = {}
    hostname_label         = "instance-20261001-1134"
    nsg_ids                = []
    private_ip             = "10.0.0.204"
    security_attributes    = {}
    skip_source_dest_check = false
    subnet_id              = "ocid1.subnet.oc1.ap-singapore-2.aaaaaaaazbppuzzgideqepnagevs5xbcbwfbvvvu3lskfaofdom3mlnydl7q"
  }
  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }
  launch_options {
    boot_volume_type                    = "PARAVIRTUALIZED"
    firmware                            = "UEFI_64"
    is_consistent_volume_naming_enabled = true
    is_pv_encryption_in_transit_enabled = true
    network_type                        = "PARAVIRTUALIZED"
    remote_data_volume_type             = "PARAVIRTUALIZED"
  }
  shape_config {
    memory_in_gbs = 12
    nvmes         = 0
    ocpus         = 2
    vcpus         = 2
  }
  source_details {
    boot_volume_size_in_gbs         = "47"
    boot_volume_vpus_per_gb         = "10"
    is_preserve_boot_volume_enabled = false
    kms_key_id                      = null
    source_id                       = "ocid1.image.oc1.ap-singapore-2.aaaaaaaan7h2srks22b2jnihsx7i5vwdurk7g6wq5wtjmnzqaghiesnintxa"
    source_type                     = "image"
  }

  # Bảo vệ máy chủ: Không bao giờ tự động tạo lại (recreate) khi có thay đổi nhỏ
  lifecycle {
    ignore_changes = [
      metadata,
      defined_tags,
      freeform_tags,
      create_vnic_details[0].defined_tags
    ]
  }
}
