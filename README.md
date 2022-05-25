## kubeadm on KVM with nginx ingress

Modify variables for environment:
  * vi group_vars/all

Install Prerequisites OS packages and pip modules for Ansible:
  * ./install_requirements.sh

Create local KVM guest VM instances:
  * ansible-playbook playbook_terraform_kvm.yml

Deploy kubeadm:
  * ansible-playbook playbook_kubeadm_dependencies.yml
  * ansible-playbook playbook_kubeadm_controlplane.yml
  * ansible-playbook playbook_kubeadm_workers.yml

MetalLB with NGINX Ingress:
  * ansible-playbook playbook_certs.yml
  * ansible-playbook playbook_metallb.yml
  * ansible-playbook playbook_nginx_ingress.yml 

Hello World deployment:
  * ansible-playbook playbook_deploy_hello.yml

Validate kubectl locally:
  * export KUBECONFIG=/tmp/kubeadm-kubeconfig
  * kubectl get services -A

Validate ingress locally:
  * add entries to local /etc/hosts
    x.y.z.145 kubeadm.local

  * test nginx ingress
    ./test-nginx-endpoints.sh
