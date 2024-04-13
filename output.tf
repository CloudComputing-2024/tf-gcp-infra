output "vpc_id" {
  value = google_compute_network.vpc_network.id
}

output "webapp_subnet_id" {
  value = google_compute_subnetwork.webapp_subnet.id
}

output "db_subnet_id" {
  value = google_compute_subnetwork.db_subnet.id
}

output "load_balancer_ip" {
  value = module.gce-lb-http.external_ip
}

output "project_number" {
  value = data.google_project.project.number
}

output "key_ring" {
  value = google_kms_key_ring.key_ring
}

output "vm_key" {
  value = google_kms_crypto_key.vm_key
}

output "cloud_sql_connnection" {
  value = google_sql_database_instance.cloud_sql_instance.connection_name
}