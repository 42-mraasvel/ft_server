service mysql start

echo "CREATE DATABASE ${WPDB_NAME};" | mysql -u root
echo "CREATE USER ${WPDB_USERNAME}@localhost IDENTIFIED BY '${WPDB_PASSWORD}';" | mysql -u root
echo "GRANT ALL PRIVILEGES ON ${WPDB_NAME}.* TO ${WPDB_USERNAME}@localhost;" | mysql -u root
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' WITH GRANT OPTION;"| mysql -u root
echo "FLUSH PRIVILEGES" | mysql -u root
echo "update mysql.user set plugin='' where user='root';"| mysql -u root
