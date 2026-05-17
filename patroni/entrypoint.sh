#!/usr/bin/env bash

# exit immediately on any command fail
set -e

# Get this container's IP address automatically
# hostname -i gives the container's IP in the docker network
export NODE_IP=$(hostname -i)

echo "Starting Patroni node: $NODE_NAME at $NODE_IP"

# Replace environment variables in patroni.yml
# envsubst replaces ${VAR} placeholders with actual values
envsubst < /etc/patroni.yml > /tmp/patroni.yml

exec patroni /tmp/patroni.yml
