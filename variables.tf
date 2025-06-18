variable "project_id" {
    type = string
    description = "GCP project ID"
}

variable "region" {
    type = string
    description = "GCP region"
    default = "europe-central2"
}

variable "zone" {
    type = string
    description = "GCP zone for the compute instance"
    default = "europe-central2-a"
}

variable "db_password" {
    type = string
    description = "value of the database password"
    sensitive = true
}