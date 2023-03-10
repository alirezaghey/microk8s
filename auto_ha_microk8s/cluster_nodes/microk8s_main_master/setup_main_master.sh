#!/usr/bin/env bash

# The following script installs the main microk8s master on an ubuntu linux
# The script expects a webserver that helps with the coordination
# between the the main master, and the other masters
# The main master send prepared connection strings to the webserver
# which will be downloaded by the rest masters to connect.
# It is noteworthy that these connection string will be invalidated upon using
# so each new master needs a new connections string

# webserver IP and port
WEBSERVER_IP=192.168.197.15
PORT=3000


apt-get update
apt-get -y install jq

# install microk8s
snap install microk8s --classic

echo $(whoami)
# enable microk8s to work without sudo
# sudo usermod -a -G microk8s $(whoami)
# sudo su - $(whoami)

# add the connections strings to the server
for i in {1..5}; do
  # create the connection string
  CONSTRING=$(microk8s add-node | head -2 | tail -1)
  # send the conn string to the server
  curl -X PUT -H "Content-Type: application/json" -d "$(jq -nc --arg constring "$CONSTRING" '{constring: $constring}')" "${WEBSERVER_IP}:${PORT}/connection-string"
done