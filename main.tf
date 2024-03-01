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

#
#  metadata = {
#    ssh-keys = "centos8:${file(var.ssh_public_key_path)}"
#  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "packer@dev-project-415121.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Appends the database configuration to application.properties
    echo "spring.datasource.url=jdbc:mysql://google/${google_sql_database.database.name}?cloudSqlInstance=${google_sql_database_instance.instance.connection_name}&socketFactory=com.google.cloud.sql.mysql.SocketFactory" > /opt/webapp/application.properties
    echo "spring.cloud.gcp.sql.database-name=${google_sql_database.database.name}" >> /opt/webapp/application.properties
    echo "spring.datasource.username=${google_sql_user.webapp_user.name}" >> /opt/webapp/application.properties
    echo "spring.sql.init.mode=always" >> /opt/webapp/application.properties
    echo "spring.datasource.password=${google_sql_user.webapp_user.password}" >> /opt/webapp/application.properties
  EOT
}

resource "google_compute_global_address" "private_ip_address" {
  provider      = google-beta
  project       = var.project_id
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  provider            = google-beta
  project             = var.project_id
  name                = "private-instance-${random_id.db_name_suffix.hex}"
  region              = "us-central1"
  database_version    = "MYSQL_8_0"
  deletion_protection = false

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier      = "db-f1-micro"
    disk_type = "PD_SSD"
    disk_size = 100
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.vpc_network.id
      enable_private_path_for_google_cloud_services = true
    }
    backup_configuration {
      binary_log_enabled = true
      enabled            = true
    }
    availability_type = "REGIONAL"
  }
}

resource "google_sql_database" "database" {
  name     = "webapp"
  instance = google_sql_database_instance.instance.name
}

resource "random_password" "password" {
  length           = 8
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_sql_user" "webapp_user" {
  name     = "webapp"
  instance = google_sql_database_instance.instance.name
  password = random_password.password.result
#  password = "123"
}

