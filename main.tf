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

  deny {
    protocol = var.disallow_ssh_protocol
    ports    = var.disallow_ssh_ports
  }

  source_ranges = var.disallow_ssh_source_ranges
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
    email  = var.service_account
    scopes = var.service_account_scope
  }

  metadata_startup_script = <<-EOT
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
  provider            = google-beta
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

