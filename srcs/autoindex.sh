NGINX_NAME='/etc/nginx/sites-available/nginx_conf'

restart_nginx()
{
	echo "Restarting nginx..."
	service nginx restart
}

if [ "$#" -ne 1 ]; then
	echo "Usage: Enable/Disable autoindex" >&2
	echo "Parameters: On/Off" >&2
	exit 1
fi

if [ $1 == "off" ]; then
	sed -i 's/autoindex on/autoindex off/g' ${NGINX_NAME}
	echo "Auto index turned off"
	restart_nginx
elif [ $1 == "on" ]; then
	sed -i 's/autoindex off/autoindex on/g' ${NGINX_NAME}
	echo "Auto index turned on"
	restart_nginx
fi

