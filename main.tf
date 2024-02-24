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
  name          = var.db_subnet_name
  ip_cidr_range = var.db_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
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

  metadata = {
    ssh-keys = "centos8:${file(var.ssh_public_key_path)}"
  }
}