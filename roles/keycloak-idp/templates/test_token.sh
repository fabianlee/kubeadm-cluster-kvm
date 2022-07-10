#!/bin/bash
#
# This is working to generate token
# but the appliation is not configured to receive this Bearer token
#

token_URL="https://keycloak.kubeadm.local/realms/myrealm/protocol/openid-connect/token"
myclient_creds="myclient:UW68opEx4YCPCSBl8VfNyd0iqvL3xaqw"
myuser_creds="username=myuser&password=Password1!"

app_URL="https://kubeadm.local/myhello/"

access_token=$(curl -ks -X POST $token_URL \
    --user $myclient_creds \
    -H 'content-type: application/x-www-form-urlencoded' \
    -d "${myuser_creds}&grant_type=password" | jq --raw-output '.access_token' \
)

if [[ "$access_token" == "null" ]]; then
  echo "ERROR could not retrieve token, check credentials"
  exit 3
else
  set -x
  curl -kvs -H "Authorization: Bearer $access_token" $app_URL
  set +x
fi
