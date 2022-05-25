#!/bin/bash

for octet in $(seq 217 219); do
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R 192.168.122.$octet
done
