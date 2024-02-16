module "vpc1" {
  source     = "./vpc-module"
  project_id = var.project_id
  region     = var.region
  vpc_name = "vpc-1"
  webapp_subnet_name = "webapp-1"
  db_subnet_name = "db-1"
  vpc_route_name = "route-to-internet-1"
}

module "vpc2" {
  source     = "./vpc-module"
  project_id = var.project_id
  region     = var.region
  vpc_name = "vpc-2"
  webapp_subnet_name = "webapp-2"
  db_subnet_name = "db-2"
  vpc_route_name = "route-to-internet-2"
}