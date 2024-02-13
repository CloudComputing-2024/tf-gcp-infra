variable "project_id" {
  description = "The project id of GCP project"
  type        = string
}

variable "region" {
  description = "The region of resources be created."
  type        = string
}

variable "vpc_name" {
  description = "The name of vpc network."
  type        = string
  default     = "custom-vpc"
}

variable "webapp_subnet_name" {
  description = "The name of the subnet for webapp."
  type        = string
  default     = "webapp"
}

variable "webapp_subnet_cidr" {
  description = "The CIDR for webapp subnet."
  type        = string
  default     = "10.0.0.0/24"
}

variable "db_subnet_name" {
  description = "The name of subnet for the databases."
  type        = string
  default     = "db"
}

variable "db_subnet_cidr" {
  description = "The CIDR for db subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "webapp_route_name" {
  description = "The name of the route for webapp."
  type        = string
  default     = "webapp-route"
}

variable "webapp_route_priority" {
  description = "The priority of the route."
  type        = number
  default     = 100
}

variable "webapp_route_dest_range" {
  description = "The destination range for the webapp-route"
  type        = string
  default     = "0.0.0.0/0"
}