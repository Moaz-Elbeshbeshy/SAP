variable "project_id" {
    type = string
    description = "GCP project ID"
}

variable "region" {
    type = string
    description = "GCP region"
    default = "us-central1"
}

variable "zone" {
    type = string
    description = "GCP zone for the compute instance"
    default = "us-central1-a"
}

variable "db_password" {
    type = string
    description = "value of the database password"
    sensitive = true
}