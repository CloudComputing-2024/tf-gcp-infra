provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  region = "us-west1"
  zone   = "us-west1-a"
}

provider "random" {}