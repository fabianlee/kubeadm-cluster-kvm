## kubeadm cluster on KVM with NGINX Ingress

[Read full blog article here](https://fabianlee.org/2022/05/25/kvm-kubeadm-cluster-on-kvm-using-ansible/)

![kubeadm cluster](https://github.com/fabianlee/kubeadm-cluster-kvm/raw/main/diagrams/kubeadm-3node.png)

Modify any variables for environment:
  * vi group_vars/all

Install Prerequisites OS packages and pip modules for Ansible:
  * ./install_requirements.sh

Create ssh keypair for guest VMs
```
cd tf-libvirt
ssh-keygen -t rsa -b 4096 -f id_rsa -C tf-libvirt -N "" -q
cd ..
```

Create local KVM guest VM instances:
  * ansible-playbook playbook_terraform_kvm.yml

Deploy kubeadm:
  * ansible-playbook playbook_kubeadm_dependencies.yml
  * ansible-playbook playbook_kubeadm_controlplane.yml
  * ansible-playbook playbook_kubeadm_workers.yml

MetalLB with NGINX Ingress:
  * ansible-playbook playbook_metallb.yml
  * ansible-playbook playbook_certs.yml
  * ansible-playbook playbook_nginx_ingress.yml 

Hello World deployment:
  * ansible-playbook playbook_deploy_myhello.yml

Validate kubectl locally:
  * export KUBECONFIG=/tmp/kubeadm-kubeconfig
  * kubectl get services -A
  * kubectl get pods -A

Validate ingress locally:
  * add entries to local /etc/hosts
```
    x.y.z.145 kubeadm.local
```

  * test myhello deployment exposed via nginx ingress
```
    ./test-nginx-endpoints.sh
```
