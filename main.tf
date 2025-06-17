resource "google_sql_database_instance" "default" {
  name             = "php-postgresql-instance"  # <-- use this exact name
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-f1-micro"  

    ip_configuration {
      ipv4_enabled        = true
      
      authorized_networks {
        name  = "my-vm-ip"
        value = "34.9.115.36"
      }
    }
  }
}

resource "google_sql_database" "app_db" {
    name     = "myappdb"
    instance = google_sql_database_instance.default.name
}

resource "google_sql_user" "app_user" {
  name     = "user"
  instance = google_sql_database_instance.default.name
  password = var.db_password
}

resource "google_compute_instance" "php_server" {
    name         = "php-web-server"
    machine_type = "e2-micro" # f1-micro is not available in many regions
    zone        = var.zone
    tags = ["http-server"]

    depends_on = [
      google_sql_database_instance.default,
      google_sql_database.app_db,
      google_sql_user.app_user
  ] 
    
    boot_disk {
      initialize_params {
        image = "debian-cloud/debian-11"
      }
    }

    network_interface {
      network = "default"
      access_config {}  // Assign external IP
    }

    metadata_startup_script = <<-EOF
  apt-get update
  apt-get install -y apache2 php php-pgsql
  systemctl start apache2
  systemctl enable apache2

  cat <<EOF_PHP > /var/www/html/index.php
${templatefile("${path.module}/php_index.tpl.php", {
    db_ip       = google_sql_database_instance.default.public_ip_address,
    db_name     = google_sql_database.app_db.name,
    db_user     = google_sql_user.app_user.name,
    db_password = var.db_password
})}
EOF_PHP
EOF
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

