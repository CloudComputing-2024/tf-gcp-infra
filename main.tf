module "vpc" {
  source             = "./vpc-module"
  project_id         = var.project_id
  region             = var.region
  vpc_name           = "vpc"
  webapp_subnet_name = "webapp"
  db_subnet_name     = "db"
  vpc_route_name     = "route-to-internet"
}
