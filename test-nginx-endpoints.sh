#!/bin/bash

domain=kubeadm.local

for h in $domain; do
  nslookup -timeout=1 $h
  if [ $? -ne 0 ]; then
    echo "WARN are you sure $h is DNS resolvable? did you add it to /etc/hosts?"
    #exit 3
  fi
done

curlopt="-k --fail --connect-timeout 3 --retry 0"
while [ 1==1 ]; do 
  timestamp=$(date +"%D %T")
  echo ""
  echo "$timestamp"
  set -x
  curl $curlopt https://$domain/myhello/
  set +x
  sleep 4
done
