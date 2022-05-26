## kubeadm cluster on KVM with NGINX Ingress

[Read full blog article here](https://fabianlee.org/2022/05/25/kvm-kubeadm-cluster-on-kvm-using-ansible/)

![kubeadm cluster](https://github.com/fabianlee/kubeadm-cluster-kvm/raw/main/diagrams/kubeadm-3node.png)

### Modify any variables for environment
  * vi group_vars/all

### Install Prerequisites OS packages and pip modules for Ansible
  * ./install_requirements.sh

### Create ssh keypair for guest VMs
```
cd tf-libvirt
ssh-keygen -t rsa -b 4096 -f id_rsa -C tf-libvirt -N "" -q
cd ..
```

### Create local KVM guest VM instances
  * ansible-playbook playbook_terraform_kvm.yml

### Deploy kubeadm
  * ansible-playbook playbook_kubeadm_dependencies.yml
  * ansible-playbook playbook_kubeadm_controlplane.yml
  * ansible-playbook playbook_kubeadm_workers.yml

wait for all pods to be ready
```
export KUBECONFIG=/tmp/kubeadm-kubeconfig
kubectl get pods -A
```

### MetalLB with NGINX Ingress
  * ansible-playbook playbook_metallb.yml
  * ansible-playbook playbook_certs.yml
  * ansible-playbook playbook_nginx_ingress.yml 

wait for NGINX Ingress to have its IP address:
```
# admission to be 'Completed', controller 'Running'
kubectl get pods -n ingress-nginx

# wait for Ingress to be provided IP address by MetalLB
kubectl get service -n ingress-nginx ingress-nginx-controller -o jsonpath="{.status.loadBalancer.ingress}"
```

### Hello World deployment
  * ansible-playbook playbook_deploy_myhello.yml

wait for deployment to be ready
```
kubectl get deployment golang-hello-world-web -n default
```


### Validate deployment at Ingress
  * test myhello deployment exposed via NGINX Ingress
```
# replace 'x.y.z' with your host network prefix, e.g. 192.168.1

# test without needing DNS
curl -k --resolve kubeadm.local:443:x.y.z.145 https://kubeadm.local:443/myhello/

# test by adding DNS to local hosts file
echo x.y.z.145 kubeadm.local | sudo tee -a /etc/hosts
curl -k https://kubeadm.local/myhello/
```
