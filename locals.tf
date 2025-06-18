locals {
  php_file_b64  = base64encode(templatefile("${path.module}/php_index.tpl.php", {
    db_ip       = google_sql_database_instance.default.ip_address[0].ip_address
    db_name     = google_sql_database.app_db.name
    db_user     = google_sql_user.app_user.name
    db_password = var.db_password
  }))
}