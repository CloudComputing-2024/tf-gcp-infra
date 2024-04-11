variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "vpc_network_auto_create_subnetworks_enabled" {
  type = bool
}

variable "vpc_network_delete_default_routes_on_create_enabled" {
  type = bool
}

variable "routing_mode" {
  type = string
}

variable "db_subnet_private_ip_google_access" {
  type = bool
}
### firewall ###
variable "allow_traffic_name" {
  type = string
}

variable "allow_traffic_protocol" {
  type = string
}

variable "allow_traffic_direction" {
  type = string
}

variable "allow_traffic_ports" {
  type = list(string)
}

variable "allow_traffic_source_ranges" {
  type = list(string)
}

variable "allow_traffic_target_tags" {
  type = list(string)
}

variable "allow_traffic_priority" {
  type = string
}

variable "allow_https_name" {
  type = string
}

variable "allow_https_direction" {
  type = string
}

variable "allow_https_priority" {
  type = number
}

variable "allow_https_source_ranges" {
  type = list(string)
}

variable "allow_https_target_tags" {
  type = list(string)
}

variable "allow_https_ports" {
  type = list(string)
}

variable "allow_https_protocol" {
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

#variable "boot_disk_image" {
#  type = string
#}
#
#variable "boot_disk_type" {
#  type = string
#}
#
#variable "boot_disk_size" {
#  type = number
#}

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

variable "load_balancer_admin" {
  type = string
}

variable "network_admin" {
  type = string
}

variable "security_admin" {
  type = string
}

variable "instance_admin" {
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

variable "cloud_dns_a_record_type" {
  type = string
}

variable "cloud_dns_a_record_ttl" {
  type = number
}

variable "cloud_dns_a_record_rrdatas" {
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

#variable "cloud_function_bucket_name" {
#  type = string
#}

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

variable "instance_template_name" {
  type = string
}

variable "instance_template_machine_type" {
  type = string
}

variable "instance_template_boot_disk_image" {
  type = string
}

variable "instance_template_auto_delete_enabled" {
  type = bool
}

variable "instance_template_boot_enabled" {
  type = bool
}

variable "instance_template_tags" {
  type = list(string)
}

variable "healthcheck_name" {
  type = string
}

variable "healthcheck_check_interval_sec" {
  type = string
}

variable "healthcheck_timeout_sec" {
  type = number
}

variable "healthcheck_healthy_threshold" {
  type = number
}

variable "healthcheck_unhealthy_threshold" {
  type = number
}

variable "healthcheck_request_path" {
  type = string
}

variable "healthcheck_port" {
  type = string
}

variable "healthcheck_log_config_enabled" {
  type = bool
}

variable "autoscaler_name" {
  type = string
}

variable "autoscaler_max_replicas" {
  type = number
}

variable "autoscaler_min_replicas" {
  type = number
}

variable "autoscaler_cooldown_period" {
  type = number
}

variable "autoscaler_cpu_utilization_target" {
  type = string
}

variable "autoscaler_max_scaled_in_replicas_percent" {
  type = number
}

variable "autoscaler_time_window_sec" {
  type = number
}

variable "autoscaler_instance_zone" {
  type = string
}

variable "instance_group_manager_base_instance_name" {
  type = string
}

variable "instance_group_manager_name" {
  type = string
}

variable "instance_group_manager_region" {
  type = string
}

variable "instance_group_distribution_policy_zones" {
  type = list(string)
}

variable "instance_group_manager_distribution_policy_target_shape" {
  type = string
}

variable "instance_group_manager_initial_delay_sec" {
  type = string
}

variable "instance_group_manager_named_port_name" {
  type = string
}

variable "instance_group_manager_named_port_port" {
  type = string
}

variable "instance_group_manager_target_size" {
  type = number
}

variable "webapp_ssl_cert_name" {
  type = string
}

variable "webapp_ssl_cert_name_domains" {
  type = list(string)
}

variable "gce_lb_http_name" {
  type = string
}

variable "gce_lb_http_managed_ssl_certificate_domains" {
  type = list(string)
}

variable "gce_lb_http_protocol" {
  type = string
}

variable "gce_lb_http_port" {
  type = number
}

variable "gce_lb_http_port_name" {
  type = string
}

variable "gce_lb_http_timeout_sec" {
  type = number
}

variable "gce_lb_http_health_check_request_path" {
  type = string
}

variable "gce_lb_http_health_check_port" {
  type = number
}

variable "gce_lb_http_sample_rate" {
  type = number
}

variable "gce_lb_http_ssl_enabled" {
  type = bool
}

variable "gce_lb_http_https_redirect_enabled" {
  type = bool
}

variable "gce_lb_http_enable_cdn_enabled" {
  type = bool
}

variable "gce_lb_http_log_config_enabled" {
  type = bool
}

variable "gce_lb_http_iap_config_enabled" {
  type = bool
}

variable "gce-lb-http_target_tags" {
  type = list(string)
}

variable "key_ring_name" {
  type = string
}

variable "vm_cmek_name" {
  type = string
}

variable "cloud_sqk_cmek_name" {
  type = string
}

variable "cloud_storage_bucket_cmek_name" {
  type = string
}