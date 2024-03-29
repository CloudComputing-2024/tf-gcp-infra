resource "google_compute_network" "vpc_network" {
  name                            = var.vpc_name
  project                         = var.project_id
  auto_create_subnetworks         = false
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
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
  private_ip_google_access = true
}

resource "google_compute_route" "default_route_to_internet" {
  name             = var.vpc_route_name
  dest_range       = var.vpc_route_dest_range
  network          = google_compute_network.vpc_network.id
  next_hop_gateway = var.next_hop_gateway
  priority         = var.vpc_route_priority
}

resource "google_compute_firewall" "allow_traffic" {
  name    = var.allow_traffic_name
  network = google_compute_network.vpc_network.id

  allow {
    protocol = var.allow_traffic_protocol
    ports    = var.allow_traffic_ports
  }
  source_ranges = var.allow_traffic_source_ranges
  target_tags   = var.allow_traffic_tags
  priority      = var.allow_traffic_priority
}

resource "google_compute_firewall" "disallow_ssh" {
  name    = var.disallow_ssh_name
  network = google_compute_network.vpc_network.name

  allow {
    protocol = var.disallow_ssh_protocol
    ports    = var.disallow_ssh_ports
  }

  source_ranges = var.disallow_ssh_source_ranges
}

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

resource "google_compute_instance" "vm_instance" {
  machine_type = var.machine_type
  name         = var.instance_name
  zone         = var.instance_zone

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      type  = var.boot_disk_type
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.webapp_subnet.id

    access_config {}
  }

  tags = [var.allow_traffic_name, var.disallow_ssh_name]

  service_account {
    email  = google_service_account.service_account.email
    scopes = var.service_account_scope
  }

  allow_stopping_for_update = true
  metadata_startup_script   = <<-EOT
    #!/bin/bash
    set -e

    # Appends the database configuration to application.properties
    sudo echo "spring.datasource.url=jdbc:mysql://google/${google_sql_database.cloud_sql_database.name}?cloudSqlInstance=${google_sql_database_instance.cloud_sql_instance.connection_name}&socketFactory=com.google.cloud.sql.mysql.SocketFactory" > /opt/webapp/application.properties
    sudo echo "spring.cloud.gcp.sql.database-name=${google_sql_database.cloud_sql_database.name}" >> /opt/webapp/application.properties
    sudo echo "spring.datasource.username=${google_sql_user.cloud_sql_user.name}" >> /opt/webapp/application.properties
    sudo echo "spring.sql.init.mode=always" >> /opt/webapp/application.properties
    sudo echo "spring.datasource.password=${google_sql_user.cloud_sql_user.password}" >> /opt/webapp/application.properties

    sudo chown -R csye6225:csye6225 /opt/webapp/application.properties
  EOT
}

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

resource "random_id" "db_name_suffix" {
  byte_length = var.db_name_suffix_byte_length
}

resource "google_sql_database_instance" "cloud_sql_instance" {
  project             = var.project_id
  name                = "private-cloud-sql-instance-${random_id.db_name_suffix.hex}"
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

data "google_dns_managed_zone" "cloud_dns_zone" {
  name = var.cloud_dns_zone_name
}

resource "google_dns_record_set" "cloud_dns_A_record" {
  name         = data.google_dns_managed_zone.cloud_dns_zone.dns_name
  type         = var.cloud_dns_A_record_type
  ttl          = var.cloud_dns_A_record_ttl
  managed_zone = data.google_dns_managed_zone.cloud_dns_zone.name
  rrdatas      = [google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip]
}

resource "google_pubsub_topic" "verify_email_topic" {
  name                       = "verify_email"
  message_retention_duration = "604800s"
}

resource "google_pubsub_subscription" "verify_email_subscription" {
  name  = "verify_email_subscription"
  topic = google_pubsub_topic.verify_email_topic.name
}

resource "google_service_account" "cloud_function_service_account" {
  account_id   = "cloud-function-service-account"
  display_name = "Cloud Function Service Account"
}

resource "google_project_iam_binding" "pubsub_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:${google_service_account.cloud_function_service_account.email}",
  ]
}
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_binding" "pubsub_token_creator_default_account" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${google_service_account.cloud_function_service_account.email}",
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_cloudfunctions_function_iam_binding" "cloud_function_viwer" {
  project        = var.project_id
  cloud_function = google_cloudfunctions_function.cloud_function_send_email_verification.name
  role           = "roles/viewer"
  members = [
    "serviceAccount:${google_service_account.cloud_function_service_account.email}",
  ]
}

resource "google_pubsub_subscription_iam_binding" "pubsub_subscription_editor" {
  subscription = google_pubsub_subscription.verify_email_subscription.name
  role         = "roles/editor"
  members = [
    "serviceAccount:${google_service_account.cloud_function_service_account.email}",
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_pubsub_topic_iam_binding" "pubsub_topic_viewer" {
  project = var.project_id
  topic   = google_pubsub_topic.verify_email_topic.name
  role    = "roles/viewer"
  members = [
    "serviceAccount:${google_service_account.cloud_function_service_account.email}",
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_cloudfunctions_function" "cloud_function_send_email_verification" {
  name        = "verification_function"
  description = "Email verification function"
  runtime     = "nodejs20"

  available_memory_mb   = 8192
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_archive.name
  entry_point           = "sendVerificationEmail"

  vpc_connector = google_vpc_access_connector.vpc_connector.id

  service_account_email = google_service_account.cloud_function_service_account.email

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.verify_email_topic.name
  }

  environment_variables = {
    DB_HOST     = google_sql_database_instance.cloud_sql_instance.private_ip_address
    DB_USER     = google_sql_user.cloud_sql_user.name
    DB_PASSWORD = google_sql_user.cloud_sql_user.password
    DB_NAME     = google_sql_database.cloud_sql_database.name
  }
}

resource "google_storage_bucket" "function_bucket" {
  name     = "send-verification-email-bucket"
  location = "US"
}

resource "google_storage_bucket_object" "function_archive" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "function-source.zip"
}

resource "google_vpc_access_connector" "vpc_connector" {
  name          = "my-vpc-connector"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.8.0.0/28"
}
