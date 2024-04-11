data "google_project" "project" {
  project_id = var.project_id
}

resource "google_compute_network" "vpc_network" {
  name                            = var.vpc_name
  project                         = var.project_id
  auto_create_subnetworks         = var.vpc_network_auto_create_subnetworks_enabled
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.vpc_network_delete_default_routes_on_create_enabled
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = var.webapp_subnet_name
  ip_cidr_range = var.webapp_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "db_subnet" {
  name                     = var.db_subnet_name
  ip_cidr_range            = var.db_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = var.db_subnet_private_ip_google_access
}

resource "google_compute_route" "default_route_to_internet" {
  name             = var.vpc_route_name
  dest_range       = var.vpc_route_dest_range
  network          = google_compute_network.vpc_network.id
  next_hop_gateway = var.next_hop_gateway
  priority         = var.vpc_route_priority
}


### firewall rules ###
resource "google_compute_firewall" "allow_traffic" {
  name          = var.allow_traffic_name
  direction     = var.allow_traffic_direction
  network       = google_compute_network.vpc_network.id
  priority      = var.allow_traffic_priority
  source_ranges = var.allow_traffic_source_ranges
  target_tags   = var.allow_traffic_target_tags

  allow {
    ports    = var.allow_traffic_ports
    protocol = var.allow_traffic_protocol
  }
}

resource "google_compute_firewall" "allow_https" {
  name          = var.allow_https_name
  direction     = var.allow_https_direction
  network       = google_compute_network.vpc_network.id
  priority      = var.allow_https_priority
  source_ranges = var.allow_https_source_ranges
  target_tags   = var.allow_https_target_tags

  allow {
    ports    = var.allow_https_ports
    protocol = var.allow_https_protocol
  }
}

resource "google_compute_firewall" "disallow_ssh" {
  name          = var.disallow_ssh_name
  network       = google_compute_network.vpc_network.name
  target_tags   = var.disallow_ssh_tags
  source_ranges = var.disallow_ssh_source_ranges

  allow {
    protocol = var.disallow_ssh_protocol
    ports    = var.disallow_ssh_ports
  }
}

### vm service account ###
resource "google_service_account" "service_account" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}

resource "google_project_iam_binding" "logging_admin" {
  project = var.project_id
  role    = var.logging_admin_role
  members = ["serviceAccount:${google_service_account.service_account.email}"]
}

resource "google_project_iam_binding" "monitoring_metric_writer" {
  project = var.project_id
  role    = var.monitoring_metric_writer_role
  members = ["serviceAccount:${google_service_account.service_account.email}"]
}

resource "google_project_iam_binding" "cloud_sql_client" {
  project = var.project_id
  role    = var.cloud_sql_role
  members = ["serviceAccount:${google_service_account.service_account.email}"]
}

resource "google_project_iam_binding" "load_balancer_admin" {
  project = var.project_id
  role    = var.load_balancer_admin
  members = ["serviceAccount:${google_service_account.service_account.email}"]
}

resource "google_project_iam_binding" "network_admin" {
  project = var.project_id
  role    = var.network_admin
  members = ["serviceAccount:${google_service_account.service_account.email}"]
}

resource "google_project_iam_binding" "security_admin" {
  project = var.project_id
  role    = var.security_admin
  members = ["serviceAccount:${google_service_account.service_account.email}"]
}

resource "google_project_iam_binding" "instance_admin" {
  project = var.project_id
  role    = var.instance_admin
  members = ["serviceAccount:${google_service_account.service_account.email}"]
}


### cloud sql ###
resource "google_compute_global_address" "private_ip_address" {
  name          = var.private_ip_address_name
  purpose       = var.private_ip_address_purpose
  address_type  = var.private_ip_address_address_type
  prefix_length = var.private_ip_address_prefix_length
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = var.private_vpc_connection_service
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "random_id" "default" {
  byte_length = var.db_name_suffix_byte_length
}

resource "google_sql_database_instance" "cloud_sql_instance" {
  project             = var.project_id
  name                = "private-cloud-sql-instance-${random_id.default.hex}"
  region              = var.cloud_sql_instance_region
  database_version    = var.cloud_sql_instance_database_version
  deletion_protection = var.cloud_sql_instance_deletion_protection

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier      = var.cloud_sql_instance_tier
    disk_type = var.cloud_sql_instance_disk_type
    disk_size = var.cloud_sql_instance_disk_size
    ip_configuration {
      ipv4_enabled                                  = var.cloud_sql_instance_ipv4_enabled
      private_network                               = google_compute_network.vpc_network.id
      enable_private_path_for_google_cloud_services = var.cloud_sql_instance_enable_private_path_for_google_cloud_services
    }

    availability_type = var.cloud_sql_instance_availability_type

    backup_configuration {
      binary_log_enabled = var.cloud_sql_instance_binary_log_enabled
      enabled            = var.cloud_sql_instance_backup_configuration_enabled
    }
  }

  encryption_key_name = google_kms_crypto_key.sql_key.id
}

resource "google_sql_database" "cloud_sql_database" {
  name     = var.cloud_sql_database_name
  instance = google_sql_database_instance.cloud_sql_instance.name
}

resource "random_password" "random_password" {
  length = var.random_password_length
}

resource "google_sql_user" "cloud_sql_user" {
  name     = var.cloud_sql_user_name
  instance = google_sql_database_instance.cloud_sql_instance.name
  password = random_password.random_password.result
}


### dns record ###
data "google_dns_managed_zone" "cloud_dns_zone" {
  name = var.cloud_dns_zone_name
}

resource "google_dns_record_set" "cloud_dns_a_record" {
  name         = data.google_dns_managed_zone.cloud_dns_zone.dns_name
  type         = var.cloud_dns_a_record_type
  ttl          = var.cloud_dns_a_record_ttl
  managed_zone = data.google_dns_managed_zone.cloud_dns_zone.name
  rrdatas      = [module.gce-lb-http.external_ip]
}


### cloud function ###
resource "google_pubsub_topic" "verify_email_topic" {
  name                       = var.verify_email_topic_name
  message_retention_duration = var.verify_email_topic_message_retention_duration
}

resource "google_pubsub_subscription" "verify_email_subscription" {
  name  = var.verify_email_subscription_name
  topic = google_pubsub_topic.verify_email_topic.name
}

resource "google_service_account" "cloud_function_service_account" {
  account_id   = var.cloud_function_service_account_account_id
  display_name = var.cloud_function_service_account_display_name
}

resource "google_project_iam_binding" "pubsub_token_creator" {
  project = var.project_id
  role    = var.pubsub_token_creator_role
  members = [
    "serviceAccount:${google_service_account.cloud_function_service_account.email}",
    "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "pubsub_publisher" {
  project = var.project_id
  role    = var.pubsub_publisher_role
  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_project_iam_binding" "pubsub_subscription_editor" {
  project = var.project_id
  role    = var.pubsub_subscription_editor_role
  members = [
    "serviceAccount:${google_service_account.cloud_function_service_account.email}",
  ]
}

resource "google_project_iam_binding" "invoking" {
  project = var.project_id
  role    = var.cloud_function_invoker_role
  members = [
    "serviceAccount:${google_service_account.cloud_function_service_account.email}",
    "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com",
  ]
  depends_on = [google_project_iam_binding.pubsub_publisher]
}

resource "google_cloudfunctions2_function" "cloud_function_send_email_verification" {
  location = var.cloud_function_send_email_verification_location
  name     = var.cloud_function_send_email_verification_name

  build_config {
    runtime     = var.cloud_function_send_email_verification_runtime
    entry_point = var.cloud_function_send_email_verification_entry_point
    source {
      storage_source {
        bucket = google_storage_bucket.cloud_function_bucket.name
        object = google_storage_bucket_object.cloud_function_archive.name
      }
    }
  }

  service_config {
    max_instance_count               = var.cloud_function_send_email_verification_max_instance_count
    min_instance_count               = var.cloud_function_send_email_verification_min_instance_count
    available_memory                 = var.cloud_function_send_email_verification_available_memory
    timeout_seconds                  = var.cloud_function_send_email_verification_timeout_seconds
    max_instance_request_concurrency = var.cloud_function_send_email_verification_max_instance_request_concurrency
    available_cpu                    = var.cloud_function_send_email_verification_available_cpu
    environment_variables            = {
      DB_HOST     = google_sql_database_instance.cloud_sql_instance.private_ip_address
      DB_USER     = google_sql_user.cloud_sql_user.name
      DB_PASSWORD = sensitive(google_sql_user.cloud_sql_user.password)
      DB_NAME     = google_sql_database.cloud_sql_database.name
      API_KEY     = var.cloud_function_send_email_verification_api_key
    }
    ingress_settings               = var.cloud_function_send_email_verification_ingress_settings
    all_traffic_on_latest_revision = var.cloud_function_send_email_verification_all_traffic_on_latest_revision
    service_account_email          = google_service_account.cloud_function_service_account.email
    vpc_connector                  = google_vpc_access_connector.vpc_connector.id
  }

  event_trigger {
    trigger_region = var.cloud_function_send_email_verification_trigger_region
    event_type     = var.cloud_function_send_email_verification_event_trigger_event_type
    pubsub_topic   = google_pubsub_topic.verify_email_topic.id
    retry_policy   = var.cloud_function_send_email_verification_retry_policy
  }

}

resource "null_resource" "cloud_function_zip" {
  provisioner "local-exec" {
    command = <<EOT
      git clone git@github.com:CloudComputing-2024/serverless.git || true
      cd serverless
      zip -r ../function-source.zip *
      cd ..
      rm -rf serverless
    EOT
  }
}

resource "google_storage_bucket" "cloud_function_bucket" {
  name     = "${random_id.default.hex}-send-verification-email-bucket"
  location = var.cloud_function_bucket_location

  encryption {
    default_kms_key_name = google_kms_crypto_key.storage_key.id
  }
}

resource "google_storage_bucket_object" "cloud_function_archive" {
  name   = var.cloud_function_archive_name
  bucket = google_storage_bucket.cloud_function_bucket.name
  source = "${path.module}/function-source.zip"
}

resource "google_vpc_access_connector" "vpc_connector" {
  name          = var.vpc_connector_name
  region        = var.vpc_connector_region
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = var.vpc_connector_ip_cidr_range
}

rtemplateesource "google_compute_instance_template" "instance_template" {
  name         = var.instance_template_name
  machine_type = var.instance_template_machine_type

  disk {
    source_image = var.instance_template_boot_disk_image
    auto_delete  = var.instance_template_auto_delete_enabled
    boot         = var.instance_template_boot_enabled

    disk_encryption_key {
      kms_key_self_link = google_kms_crypto_key.vm_key.id
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.webapp_subnet.id
    access_config {}
  }

  tags = var.instance_template_tags
  service_account {
    email  = google_service_account.service_account.email
    scopes = var.service_account_scope
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e

    # Appends the database configuration to application.properties
    sudo echo "spring.datasource.url=jdbc:mysql://google/${google_sql_database.cloud_sql_database.name}?cloudSqlInstance=${google_sql_database_instance.cloud_sql_instance.connection_name}&socketFactory=com.google.cloud.sql.mysql.SocketFactory" > /opt/webapp/application.properties
    sudo echo "spring.cloud.gcp.sql.database-name=${google_sql_database.cloud_sql_database.name}" >> /opt/webapp/application.properties
    sudo echo "spring.datasource.username=${google_sql_user.cloud_sql_user.name}" >> /opt/webapp/application.properties
    sudo echo "spring.sql.init.mode=never" >> /opt/webapp/application.properties
    sudo echo "spring.datasource.password=${google_sql_user.cloud_sql_user.password}" >> /opt/webapp/application.properties
    sudo echo "GOOGLE_CLOUD_PROJECT=${var.project_id}" >> /opt/webapp/application.properties
    sudo echo "PUBSUB_TOPIC=${google_pubsub_topic.verify_email_topic.name}" >> /opt/webapp/application.properties

    sudo chown -R csye6225:csye6225 /opt/webapp/application.properties
  EOT
}


### health check ###
resource "google_compute_health_check" "healthcheck" {
  name                = var.healthcheck_name
  check_interval_sec  = var.healthcheck_check_interval_sec
  timeout_sec         = var.healthcheck_timeout_sec
  healthy_threshold   = var.healthcheck_healthy_threshold
  unhealthy_threshold = var.healthcheck_unhealthy_threshold

  http_health_check {
    request_path = var.healthcheck_request_path
    port         = var.healthcheck_port
  }

  log_config {
    enable = var.healthcheck_log_config_enabled
  }
}

### autoscaler ###
resource "google_compute_autoscaler" "autoscaler" {
  name   = var.autoscaler_name
  zone   = var.autoscaler_instance_zone
  target = google_compute_instance_group_manager.instance_group_manager.id

  autoscaling_policy {
    max_replicas    = var.autoscaler_max_replicas
    min_replicas    = var.autoscaler_min_replicas
    cooldown_period = var.autoscaler_cooldown_period

    cpu_utilization {
      target = var.autoscaler_cpu_utilization_target
    }

    scale_in_control {
      max_scaled_in_replicas {
        percent = var.autoscaler_max_scaled_in_replicas_percent
      }
      time_window_sec = var.autoscaler_time_window_sec
    }
  }
}

### instance group manager ###
resource "google_compute_instance_group_manager" "instance_group_manager" {
  name               = var.instance_group_manager_name
  base_instance_name = var.instance_group_manager_base_instance_name

  target_size = var.instance_group_manager_target_size
  zone        = var.autoscaler_instance_zone

  version {
    instance_template = google_compute_instance_template.instance_template.id
  }

  named_port {
    name = var.instance_group_manager_named_port_name
    port = var.instance_group_manager_named_port_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.healthcheck.id
    initial_delay_sec = var.instance_group_manager_initial_delay_sec
  }
}

### ssl certificate ###
resource "google_compute_managed_ssl_certificate" "webapp_ssl_cert" {
  provider = google-beta
  project  = var.project_id
  name     = var.webapp_ssl_cert_name

  managed {
    domains = var.webapp_ssl_cert_name_domains
  }
}

### load balancer ###
module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 9.0"

  name    = var.gce_lb_http_name
  project = var.project_id

  target_tags = var.gce-lb-http_target_tags

  ssl                             = var.gce_lb_http_ssl_enabled
  managed_ssl_certificate_domains = var.gce_lb_http_managed_ssl_certificate_domains
  https_redirect                  = var.gce_lb_http_https_redirect_enabled

  backends = {
    default = {

      protocol    = var.gce_lb_http_protocol
      port        = var.gce_lb_http_port
      port_name   = var.gce_lb_http_port_name
      timeout_sec = var.gce_lb_http_timeout_sec
      enable_cdn  = var.gce_lb_http_enable_cdn_enabled

      health_check = {
        request_path = var.gce_lb_http_health_check_request_path
        port         = var.gce_lb_http_health_check_port
      }

      log_config = {
        enable      = var.gce_lb_http_log_config_enabled
        sample_rate = var.gce_lb_http_sample_rate
      }

      groups = [
        {
          group = google_compute_instance_group_manager.instance_group_manager.instance_group
        }
      ]

      iap_config = {
        enable = var.gce_lb_http_iap_config_enabled
      }
    }
  }
}

resource "random_id" "keyring_name" {
  byte_length = 4
  prefix      = "keyring-"
}

resource "random_id" "vm_key_name" {
  byte_length = 4
  prefix      = "vm-key-"
}

resource "random_id" "sql_key_name" {
  byte_length = 4
  prefix      = "sql-key-"
}

resource "random_id" "storage_key_name" {
  byte_length = 4
  prefix      = "storage-key-"
}

resource "google_kms_key_ring" "key_ring" {
  name     = random_id.keyring_name.hex
  location = var.region
}

resource "google_kms_crypto_key" "vm_key" {
  name            = random_id.vm_key_name.hex
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "2592000s"
}


resource "google_kms_crypto_key" "sql_key" {
  name            = random_id.sql_key_name.hex
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "2592000s"
}


resource "google_kms_crypto_key" "storage_key" {
  name            = random_id.storage_key_name.hex
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "2592000s"
}

resource "google_kms_crypto_key_iam_binding" "vm_key_iam_binding" {
  crypto_key_id = google_kms_crypto_key.vm_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
#    "serviceAccount:${data.google_project.project.number}@cloudservices.gserviceaccount.com",
#    "serviceAccount:service-${data.google_project.project.number}@gcp-sa-eventarc.iam.gserviceaccount.com"
  ]
}

resource "google_kms_crypto_key_iam_binding" "sql_key_iam_binding" {
  crypto_key_id = google_kms_crypto_key.sql_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
    "serviceAccount:${google_project_service_identity.cloudsql_service_identity.email}"
  ]
}

resource "google_kms_crypto_key_iam_binding" "storage_key_iam_binding" {
  crypto_key_id = google_kms_crypto_key.storage_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:service-${data.google_project.project.number}@gs-project-accounts.iam.gserviceaccount.com"
  ]
}

resource "google_project_service_identity" "cloudsql_service_identity" {
  provider = google-beta
  project  = var.project_id
  service  = "sqladmin.googleapis.com"
}

resource "google_project_iam_binding" "cryptokey_encrypter_decrypter" {
  project = var.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:${google_service_account.service_account.email}",
    "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
#    "serviceAccount:${data.google_project.project.number}@cloudservices.gserviceaccount.com",
#    "serviceAccount:service-${data.google_project.project.number}@gcp-sa-eventarc.iam.gserviceaccount.com"
  ]
}
