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

variable "firewall_name" {
  type = string
}

variable "protocol_name" {
  type = string
}

variable "application_port" {
  type    = list(string)
  default = ["8080"]
}

variable "firewall_source_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]
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

variable "firewall_tags" {
  type = list(string)
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

