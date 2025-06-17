variable "project_id" {
    description = "GCP project ID"
    type = string

}

variable "region" {
    description = "GCP region"
    type = string
    default = "us-central1"
}
variable "db_password" {
    type        = string
    description = "Password for the PostgreSQL user"
    sensitive   = true
}

variable "zone" {
  type        = string
  description = "GCP zone for the compute instance"
  default     = "us-central1-a"  # Change to your preferred zone
}