output "vpc_id" {
  value = google_compute_network.vpc_network.id
}

output "webapp_subnet_id" {
  value = google_compute_subnetwork.webapp_subnet.id
}

output "db_subnet_id" {
  value = google_compute_subnetwork.db_subnet.id
}

