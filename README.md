<strong>Based on</strong>
https://gitlab.com/worldofmatthew/automatic-tor-nginx

Automatic Tor NGINX
Automatic Tor+Nginx is a bash script that automatically installs Tor and NGINX and automatically configures them to create a hidden website accessible through the Tor network.

System Requirements:
Debian 10 (only tested with 64bit).  DO NOT DEVIATE FROM THIS.  Debian 10, 64Bit or stop the install.

Installation instructions:

Download the bash script:

set the correct permissions:
chmod +x tor.sh

Run the bash script:
./tornginx.sh
After installation is complete, you will be provided both your onion v3 hostname and the WWW directory that NGINX in configured to use.
