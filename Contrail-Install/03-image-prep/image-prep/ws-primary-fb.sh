#########################################
# Set the secondary webserver ip (ws_ip) here
# Set the database server ip here (db_ip)
##########################################
ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
sudo sshpass -p "juniper123" ssh-copy-id -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa.pub root@$ws_ip
sudo sshpass -p "juniper123" ssh-copy-id -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa.pub ubuntu@$ws_ip
echo "ssh pass completed"
sudo rsync -r /var/www/* root@$ws_ip:/var/www/.
echo "rsync completed"
sudo ssh ubuntu@$ws_ip 'sudo service apache2 restart'
echo "remotely executed apache restart"
sed -i "/host/c\host = '$ws_ip'," /etc/lsyncd/lsyncd.conf.lua
echo "set host in lsyncd config file"
sudo service lsyncd start
echo "started the lsyncd process"
sudo service lsyncd restart


#Automating the Wordpress setup
MY_IFACE=`route | grep '^default' | grep -o '[^ ]*$'`
MY_IP=`/sbin/ifconfig $MY_IFACE $1 | grep "inet" | awk -F' ' '{print $2}'| awk -F ':' '{print $2}'|awk "NR==1"`
echo "my ip:"
echo $MY_IP
BASE_URL="http://$MY_IP"

#Databse info
DB_USER="wpuser"
DB_PASS="password"
DB_NAME="wordpress"
DB_HOST=$db_ip
DEST="jnpr-example.com"
SITE_PATH=/var/www/html/jnpr-example.com/public_html/
 


sudo -u www-data -s -- <<EOF  
echo 'Updating jnpr-example.com...'  
wp core config --path=$SITE_PATH --dbhost=$DB_HOST --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASS --extra-php <<PHP
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', true);
define('WP_MEMORY_LIMIT', '256M');
PHP
wp core install --path=$SITE_PATH --url=$BASE_URL/$DEST --title=Lara-Example --admin_user=test --admin_password=test --admin_email=lara@lara-example.com
echo  
EOF


# Download WP Core.
#wp core download --path=$SITE_PATH

# Generate the wp-config.php file
#wp core config --path=$SITE_PATH --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASS --extra-php <<PHP
#define('WP_DEBUG', true);
#define('WP_DEBUG_LOG', true);
#define('WP_DEBUG_DISPLAY', true);
#define('WP_MEMORY_LIMIT', '256M');
#PHP

# Install the WordPress database.
#wp core install --path=$SITE_PATH --url=$BASE_URL/$DEST --title=Lara-Example --admin_user=test --admin_password=test --admin_email=lara@lara-example.com
