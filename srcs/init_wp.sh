WP_DIR='/tmp/wordpress'

cp ${WP_DIR}/wp-config-sample.php ${WP_DIR}/wp-config.php
sed -i "s/database_name_here/$WPDB_NAME/g" ${WP_DIR}/wp-config.php
sed -i "s/username_here/$WPDB_USERNAME/g" ${WP_DIR}/wp-config.php
sed -i "s/password_here/$WPDB_PASSWORD/g" ${WP_DIR}/wp-config.php
# sed -i "s/define( 'WP_DEBUG', false );/define( 'WP_DEBUG', true );/g" ${WP_DIR}/wp-config.php

chown -R www-data:www-data ${WP_DIR}
chmod -R 755 ${WP_DIR}
cp -a ${WP_DIR} /var/www/html

wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp-cli
service mysql start
wp-cli core install --allow-root --title="Ft_Server Wordpress" --admin_name="${WP_ADMIN}" --admin_password="${WP_PASSWORD}" --admin_email="${WP_EMAIL}" --path="/var/www/html/wordpress" --url="http://localhost/wordpress"
