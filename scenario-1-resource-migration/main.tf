# imported resource block
resource "aws_instance" "scenario-1-import" {
  ami                                  = "ami-02521d90e7410d9f0"
  associate_public_ip_address          = false
  availability_zone                    = "ap-south-1b"
  disable_api_stop                     = false
  disable_api_termination              = false
  ebs_optimized                        = false
  enable_primary_ipv6                  = null
  get_password_data                    = false
  hibernation                          = false
  host_id                              = null
  host_resource_group_arn              = null
  iam_instance_profile                 = null
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t2.nano"
  ipv6_address_count                   = 0
  ipv6_addresses                       = []
  key_name                             = "SOME_KEY"
  monitoring                           = false
  placement_group                      = null
  placement_partition_number           = 0
  private_ip                           = "172.x.x.x"
  secondary_private_ips                = []
  security_groups                      = ["sg-2x-5!o"]
  source_dest_check                    = true
  subnet_id                            = "subnet-sXXXXXfbxx1d91"
  tags = {
    Name = "test-instance"
  }
  tags_all = {
    Name = "test-instance"
  }
  tenancy                     = "default"
  user_data                   = null
  user_data_base64            = null
  user_data_replace_on_change = null
  volume_tags                 = null
  vpc_security_group_ids      = ["sg-xxxx0fxcxxx5b1"]
  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }
  cpu_options {
    amd_sev_snp      = null
    core_count       = 2
    threads_per_core = 1
  }
  credit_specification {
    cpu_credits = "standard"
  }
  enclave_options {
    enabled = false
  }
  maintenance_options {
    auto_recovery = "default"
  }
  metadata_options {
    http_endpoint               = "disabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }
  private_dns_name_options {
    enable_resource_name_dns_a_record    = true
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 3000
    kms_key_id            = null
    tags                  = {}
    tags_all              = {}
    throughput            = 105
    volume_size           = 10
    volume_type           = "gp3"
  }
}
