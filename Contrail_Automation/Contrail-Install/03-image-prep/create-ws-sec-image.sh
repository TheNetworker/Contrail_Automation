#Make a copy of original ubuntu image to work upon
cp images/ubuntu-image.img images/ubuntu-sec.img

#set environment for libvirt
export LIBGUESTFS_BACKEND=direct

#customize the webserver secondary image
virt-customize -a images/ubuntu-sec.img \
--root-password password:juniper123 \
--hostname ws-sec \
--run-command 'echo "ubuntu ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/ubuntu' \
--chmod 0440:/etc/sudoers.d/ubuntu \
--copy-in firstboots.sh/secfb:/root/ \
--install mysql-server,mysql-client,nginx,php-fpm,php-mysql \
--install php-curl,php-gd,php-mbstring,php-mcrypt,php-xml,php-xmlrpc \
--run-command 'sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config' \
--run-command 'sed -i "/^PermitRootLogin/c\PermitRootLogin  yes" /etc/ssh/sshd_config' \
--copy-in configs/default:/etc/nginx/sites-available/ \
--run-command 'systemctl reload nginx'
