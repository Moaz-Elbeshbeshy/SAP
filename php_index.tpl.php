<?php
$conn = pg_connect("host=${db_ip} dbname=${db_name} user=${db_user} password=${db_password}");
if (!$conn) {
    die('Could not connect: ' . pg_last_error());
}
echo 'Alma.com served successfully';
pg_close($conn);
?>
