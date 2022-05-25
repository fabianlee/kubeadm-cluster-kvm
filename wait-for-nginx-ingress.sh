#!/bin/bash
#
# Waits until nginx ingress has loadBalancer
#


while [[ -z $(kubectl get service -n ingress-nginx ingress-nginx-controller -o jsonpath="{.status.loadBalancer.ingress}" 2>/dev/null) ]]; do
  echo "still waiting for ingress-nginx/ingress-nginx-controller to get ingress"
  sleep 1
done
echo "ingress-nginx/ingress-nginx-controller has ingress"
