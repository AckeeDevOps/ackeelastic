#!/bin/sh

# provision elasticsearch user
addgroup sudo
adduser -D -g '' elasticsearch
adduser elasticsearch sudo
chown -R elasticsearch /elasticsearch /data
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# allow for memlock
ulimit -l unlimited

# Ackee: add backup credentials to ES config dir

echo "$GS_CRED_FILE_CONTENT" | base64 -d > /elasticsearch/config/gs.json
chown elasticsearch /elasticsearch/config/gs.json
chmod 600 /elasticsearch/config/gs.json

# run
sudo -E -u elasticsearch /elasticsearch/bin/elasticsearch

