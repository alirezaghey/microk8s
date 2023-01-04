#!/usr/bin/env bash

# The following script installs the other k8s master on a Flatcar linux
# The script assumes that SELinux is disabled by other means (in this case we do it per butane config files), as
# the current Flatcar implementation of SELinux doens't work with Cilium
# The script expects a webserver that helps with the coordination of IPs, certs and tokens
# between the loadbalancer, the main master, the other masters, and the worker nodes
# In this case, the secondary masters, upload their ips to the webserver,
# and get the IP of the loadbalancer, the token, discovery token, and the k8s certs from the webserver 

# webserver IP and port
WEBSERVER_IP=192.168.197.15
PORT=3000

apt-get update
snap install microk8s --classic

# Get connection string from main master
connection_string=$(curl "http://${WEBSERVER_IP}:${PORT}/connection-string" 2>/dev/null)
while [ -z "$connection_string" ]
do
    # echo "one time"
    # echo $loadbalancer_ip_exists
    sleep 5
    connection_string=$(curl "http://${WEBSERVER_IP}:${PORT}/connection-string" 2>/dev/null)
done

$connection_string