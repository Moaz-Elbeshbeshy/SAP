resource "google_sql_database_instance" "default" {
  name             = "my-postgresql-instance"  # <-- use this exact name
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-custom-1-3840"  # match the tier of your instance
    ip_configuration {
      authorized_networks = []
      ipv4_enabled        = true
    }
  }
}

resource "google_sql_database" "app_db" {
    name     = "myappdb"
    instance = google_sql_database_instance.default.name
}

resource "google_sql_user" "app_user" {
  name = "user"
  instance = google_sql_database_instance.default.name
  password = "secret"
}
