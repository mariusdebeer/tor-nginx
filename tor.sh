#!/bin/bash

# Automatic NGINX and TOR Hidden Service Installer 1.0
echo "WARNING: THIS SCRIPT CAN ONLY BE USED WITH DEBIAN 10. DO NOT USE WITH ANY OTHER OS."
echo "This installer should on be used with clean install of Debian 10 as it wipes existing Tor and NGiNX settings"
echo "By using this installer you agree not to use this installer to:"
echo "create websites with child porn or terroist content."
echo "create websites with content that is illegal were you live"
echo "claim that I endorse or promote any site created with this script."
echo -n "Do you agree with this? [yes or no]: "
read yno
case $yno in

        [yY] | [yY][Ee][Ss] )
                echo "Agreed"
                ;;

        [nN] | [n|N][O|o] )
                echo "Not agreed, you can't proceed the installation";
                exit 1
                ;;
        *) echo "Invalid input"
            ;;
			
esac
# Pre-installation
timedatectl set-timezone Etc/UTC
apt-get update
apt-get upgrade -y
apt-get install curl gnupg apt-transport-https apt unattended-upgrades apt-listchanges apt-transport-tor iptables iptables-persistent -y
#Update sources.list

echo deb https://deb.torproject.org/torproject.org buster main >> /etc/apt/sources.list.d/tor.list
echo deb-src https://deb.torproject.org/torproject.org buster main >> /etc/apt/sources.list.d/tor.list

# Add signing key
curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add 
# Install TOR
apt update
apt install tor deb.torproject.org-keyring -y
# Enable Tor at boot
systemctl enable tor
# Install Nginx
apt install nginx -y
systemctl enable nginx
# Add hidden service
cat /dev/null >> /etc/tor/torrc
cat <<EOT >> /etc/tor/torrc
RunAsDaemon 1
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServicePort 80 127.0.0.1:8080

EOT

# Add permissions for hidden service
mkdir /var/lib/tor/hidden_service/
chown debian-tor:debian-tor /var/lib/tor/hidden_service/ 
chmod 0700 /var/lib/tor/hidden_service/
# Make folder for hidden website
mkdir /var/hiddenwww/
echo "TOR Hidden Nginx Install Successful" > /var/hiddenwww/index.html
chmod -R 755 /var/hiddenwww/
chown -R "$USER":www-data /var/hiddenwww/
# Securing Nginx
cat /dev/null > /etc/nginx/nginx.conf
cat <<EOT >> /etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 50000;
	# multi_accept on;
}

http {

	##
	# Basic Settings
	##
	sendfile on;
	tcp_nopush on;
	tcp_nodelay on;
	keepalive_timeout 65;
	types_hash_max_size 2048;
	server_tokens off;
	server_name_in_redirect off;
    port_in_redirect off;
	server_names_hash_bucket_size 64;
	include /etc/nginx/mime.types;
	default_type application/octet-stream;

#	gzip on;

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}
EOT

# Writing new virtual host
cat <<EOT >> /etc/nginx/sites-available/hiddenwww.conf
server {
listen 127.0.0.1:8080;
root /var/hiddenwww/;
location / {
    autoindex off; 
}
charset utf-8;
index index.html;
}
EOT
# Symlink to new virtual host
ln -s /etc/nginx/sites-available/hiddenwww.conf /etc/nginx/sites-enabled/hiddenwww.conf
# restart
systemctl restart tor
systemctl restart nginx
#wait
echo 'Waiting for one minute for TOR to start correctly.'
sleep 60
#Changing Tor update to hidden service address and update apt
cat /dev/null > /etc/apt/sources.list.d/tor.list
sleep 1
echo deb tor://sdscoq7snqtznauu.onion/torproject.org buster main >> /etc/apt/sources.list.d/tor.list
echo deb-src tor://sdscoq7snqtznauu.onion/torproject.org buster main >> /etc/apt/sources.list.d/tor.list
sleep 1
#Update Debian Buster Repository to hidden service
cat /dev/null > /etc/apt/sources.list
echo deb tor+http://vwakviie2ienjx6t.onion/debian buster main >> /etc/apt/sources.list
echo deb-src tor+http://vwakviie2ienjx6t.onion/debian buster main >> /etc/apt/sources.list
echo deb tor+http://vwakviie2ienjx6t.onion/debian buster-updates main >> /etc/apt/sources.list
echo deb-src tor+http://vwakviie2ienjx6t.onion/debian buster-updates main >> /etc/apt/sources.list
echo deb tor+http://sgvtcaew4bxjd7ln.onion/debian-security buster/updates main >> /etc/apt/sources.list
echo deb-src tor+http://sgvtcaew4bxjd7ln.onion/debian-security buster/updates main >> /etc/apt/sources.list
echo deb tor+http://vwakviie2ienjx6t.onion/debian buster-backports  main >> /etc/apt/sources.list
echo deb-src tor+http://vwakviie2ienjx6t.onion/debian buster-backports  main >> /etc/apt/sources.list
apt-get update
#Iptables to avoid leaks
iptables -F
iptables -A INPUT -p tcp --dport 80 -j DROP
iptables -A INPUT -p tcp --dport 443 -j DROP
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6
#Clear display
clear
#Text output
echo
echo "NGINX + TOR hidden service installed."
echo "Your Hidden Web Address: $(</var/lib/tor/hidden_service/hostname)"
echo "Your WWW directory is location at: /var/hiddenwww/"
