provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  region = "us-central1"
  zone   = "us-central1-a"
}

provider "random" {}