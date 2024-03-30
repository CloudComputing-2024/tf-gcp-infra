variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "routing_mode" {
  type = string
}

variable "allow_traffic_name" {
  type = string
}

variable "allow_traffic_protocol" {
  type = string
}

variable "allow_traffic_ports" {
  type    = list(string)
  default = ["8080"]
}

variable "allow_traffic_source_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "allow_traffic_tags" {
  type = list(string)
}

variable "allow_traffic_priority" {
  type = string
}

variable "disallow_ssh_name" {
  type = string
}

variable "disallow_ssh_protocol" {
  type = string
}

variable "disallow_ssh_ports" {
  type    = list(string)
  default = ["22"]
}

variable "disallow_ssh_source_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "disallow_ssh_tags" {
  type = list(string)
}

variable "webapp_subnet_name" {
  type = string
}

variable "webapp_subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "db_subnet_name" {
  type = string
}

variable "db_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "vpc_route_name" {
  type = string
}

variable "vpc_route_priority" {
  type    = number
  default = 100
}

variable "vpc_route_dest_range" {
  type    = string
  default = "0.0.0.0/0"
}

variable "next_hop_gateway" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "instance_zone" {
  type = string
}

variable "boot_disk_image" {
  type = string
}

variable "boot_disk_type" {
  type = string
}

variable "boot_disk_size" {
  type = number
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "service_account_id" {
  type = string
}

variable "service_account_display_name" {
  type = string
}

variable "service_account_scope" {
  type = list(string)
}

variable "logging_admin_role" {
  type = string
}

variable "monitoring_metric_writer_role" {
  type = string
}

variable "cloud_sql_role" {
  type = string
}

variable "private_ip_address_name" {
  type = string
}

variable "private_ip_address_purpose" {
  type = string
}

variable "private_ip_address_address_type" {
  type = string
}

variable "private_ip_address_prefix_length" {
  type = number
}

variable "private_vpc_connection_service" {
  type = string
}


variable "db_name_suffix_byte_length" {
  type = number
}

variable "cloud_sql_instance_region" {
  type = string
}

variable "cloud_sql_instance_database_version" {
  type = string
}

variable "cloud_sql_instance_deletion_protection" {
  type    = bool
  default = false
}

variable "cloud_sql_instance_tier" {
  type = string
}

variable "cloud_sql_instance_disk_type" {
  type = string
}

variable "cloud_sql_instance_disk_size" {
  type = number
}

variable "cloud_sql_instance_ipv4_enabled" {
  type    = bool
  default = false
}

variable "cloud_sql_instance_enable_private_path_for_google_cloud_services" {
  type    = bool
  default = true
}

variable "cloud_sql_instance_binary_log_enabled" {
  type    = bool
  default = true
}

variable "cloud_sql_instance_backup_configuration_enabled" {
  type    = bool
  default = true
}

variable "cloud_sql_instance_availability_type" {
  type = string
}

variable "cloud_sql_database_name" {
  type = string
}

variable "random_password_length" {
  type = number
}

variable "cloud_sql_user_name" {
  type = string
}

variable "cloud_dns_zone_name" {
  type = string
}

variable "cloud_dns_A_record_type" {
  type = string
}

variable "cloud_dns_A_record_ttl" {
  type = number
}

variable "cloud_dns_A_record_rrdatas" {
  type = list(string)
}

variable "verify_email_topic_name" {
  type = string
}

variable "verify_email_topic_message_retention_duration" {
  type = string
}

variable "verify_email_subscription_name" {
  type = string
}

variable "cloud_function_service_account_account_id" {
  type = string
}

variable "cloud_function_service_account_display_name" {
  type = string
}

variable "pubsub_token_creator_role" {
  type = string
}

variable "pubsub_publisher_role" {
  type = string
}

variable "cloud_function_invoker_role" {
  type = string
}

variable "pubsub_subscription_editor_role" {
  type = string
}

variable "pubsub_topic_viewer_role" {
  type = string
}

variable "event_receiving_role" {
  type = string
}

variable "cloud_function_send_email_verification_location" {
  type = string
}

variable "cloud_function_send_email_verification_name" {
  type = string
}

variable "cloud_function_send_email_verification_max_instance_count" {
  type = number
}


variable "cloud_function_send_email_verification_min_instance_count" {
  type = number
}

variable "cloud_function_send_email_verification_available_memory" {
  type = string
}


variable "cloud_function_send_email_verification_timeout_seconds" {
  type = string
}

variable "cloud_function_send_email_verification_runtime" {
  type = string
}

variable "cloud_function_send_email_verification_max_instance_request_concurrency" {
  type = number
}

variable "cloud_function_send_email_verification_available_cpu" {
  type = number
}

variable "cloud_function_send_email_verification_ingress_settings" {
  type = string
}

variable "cloud_function_send_email_verification_all_traffic_on_latest_revision" {
  type = bool
}

variable "cloud_function_send_email_verification_trigger_region" {
  type = string
}


variable "cloud_function_send_email_verification_entry_point" {
  type = string
}

variable "cloud_function_send_email_verification_event_trigger_event_type" {
  type = string
}

variable "cloud_function_send_email_verification_retry_policy" {
  type = string
}

variable "cloud_function_send_email_verification_api_key" {
  type = string
}

variable "cloud_function_bucket_name" {
  type = string
}

variable "cloud_function_bucket_location" {
  type = string
}

variable "cloud_function_archive_name" {
  type = string
}

variable "vpc_connector_name" {
  type = string
}

variable "vpc_connector_region" {
  type = string
}

variable "vpc_connector_ip_cidr_range" {
  type = string
}
