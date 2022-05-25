
while [[ -z $(kubectl get service -n ingress-nginx ingress-nginx-controller -o jsonpath="{.status.loadBalancer.ingress}" 2>/dev/null) ]]; do
  echo "still waiting for ingress-nginx/ingress-nginx-controller to get ingress"
  sleep 1
done
echo "ingress-nginx/ingress-nginx-controller has ingress"

exit 0
pod_dump=$(kubectl get pods -A -o=jsonpath="{range .items[*]}{.metadata.namespace},{.metadata.name}{'\n'}{end}")

IFS=$'\n'
for line in $pod_dump; do
  ns_field=$(echo $line | awk -F, {'print $1'})
  pod_field=$(echo $line | awk -F, {'print $2'})
  kubectl get pod $pod_field --namespace $ns_field
done
