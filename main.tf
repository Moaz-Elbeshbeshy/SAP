resource "google_compute_address" "vm_static_ip" {
    name     = "php-vm-static-ip"
    region   = var.region
}

resource "google_sql_database_instance" "default" {
    name                = "php-postgresql-instance"
    database_version    = "POSTGRES_14"
    region              = var.region

    depends_on = [ google_compute_address.vm_static_ip ]

    settings {
        tier = "db-f1-micro"

        ip_configuration {
            ipv4_enabled = true

            authorized_networks {
                name = "php-vm-static-ip"
                value = google_compute_address.vm_static_ip.address
            }
        }
    }  
}

resource "google_sql_database" "app_db" {
    name = "my-app-db"
    instance = google_sql_database_instance.default.name

    depends_on = [ google_sql_database_instance.default ]
}

resource "google_sql_user" "app_user" {
    name        = "mizo"
    instance    = google_sql_database_instance.default.name
    password    = var.db_password

    depends_on  = [ google_sql_database_instance.default ]
}

resource "google_compute_instance" "php_server" {
    name            = "php-server"
    machine_type    = "e2-micro"
    zone            = var.zone
    tags            = ["http-server"]

    depends_on      = [
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
        access_config {
            nat_ip = google_compute_address.vm_static_ip.address
        }
    }

    metadata_startup_script = <<-EOF
        apt-get update
        apt-get install -y apache2 php php-pgsql

        # Prioritize index.php over index.html
        sed -i 's/DirectoryIndex .*/DirectoryIndex index.php index.html/' /etc/apache2/mods-enabled/dir.conf
        
        systemctl start apache2
        systemctl enable apache2

        # Create index.php from base64 decoded content
        echo "${local.php_file_b64}" | base64 -d > /var/www/html/index.php

        systemctl restart apache2
    EOF
}   

resource "google_compute_firewall" "allow_http" {
    name = "allow-http"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["http-server"]
}

resource "google_compute_firewall" "allow_ssh" {
    name = "allow-ssh"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_ranges = ["37.76.40.225/32"] # My home IP address to be able to SSH into the instance
    target_tags = ["http-server"]
}