terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"  # or a newer version like 5.x if available
    }
  }
}

provider "google" {
    project = var.project_id
    region = var.region
}