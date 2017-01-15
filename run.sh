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

if [ -z "$GS_CRED_FILE_CONTENT" -o "$GS_NO_BACKUP" == "yes" ]; then
    echo "You have to provide base64 encoded private key for GCS snapshots in \$GS_CRED_FILE_CONTENT or set \$GS_NO_BACKUP to \"yes\". Refusing to continue."
    exit 1
fi

if [ "$GS_NO_BACKUP" != "yes"]; then
  echo "$GS_CRED_FILE_CONTENT" | base64 -d > /elasticsearch/config/gs.json
  chown elasticsearch /elasticsearch/config/gs.json
  chmod 600 /elasticsearch/config/gs.json
fi

# run
sudo -E -u elasticsearch /elasticsearch/bin/elasticsearch

