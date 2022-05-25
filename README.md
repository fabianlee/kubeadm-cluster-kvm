## kubeadm on KVM with nginx ingress

Modify variables for environment:
  * vi group_vars/all

Install Prerequisites modules for Ansible:
  * ansible-playbook install_dependencies.yml

Create local KVM guest VM instances:
  * ansible-playbook playbook_terraform_kvm.yml

Deploy kubeadm:
  * ansible-playbook playbook_kubeadm_dependencies.yml
  * ansible-playbook playbook_kubeadm_controlplane.yml
  * ansible-playbook playbook_kubeadm_workers.yml

---
MetalLB with NGINX Ingress:
  * ansible-playbook playbook_certs.yml
  * ansible-playbook playbook_metallb_nginx.yml

Validate kubectl locally:
  * export KUBECONFIG=/tmp/kubeadm-kubeconfig
  * kubectl get services -A

Validate ingress locally:
  * add entries to local /etc/hosts
    192.168.2.145 kubeadm.local

  * test nginx ingress
    ./test-nginx-endpoints.sh
