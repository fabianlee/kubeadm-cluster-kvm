#!/bin/bash
#
# menu to show available actions
#
BIN_DIR=$(dirname ${BASH_SOURCE[0]})
cd $BIN_DIR

# visual marker for task
declare -A done_status

# BASH does not support multi-dimensional/complex datastructures
# 1st column = action
# 2nd column = description
menu_items=(
  "prereq,Prerequisites for OS, pip, Ansible"
  "sshkeypair,Create SSH keypair for guest OS logins"
  "tf,Create local KVM guest VMs using terraform"
  "ansibleping,Verify that ansible can reach guest VMS"
  "ssh,Manual ssh into guest VMs"
  ""
  "kubeadm-prep,Prepare guest VMs for kubeadm install"
  "kubeadm-control,Install kubedm control plane"
  "kubeadm-workers,Have workers join kubeadm cluster"
  ""
  "metallb,Configure MetalLB to provide IP addresses to LB"
  "certs,Generate and load TLS certificates into cluster"
  "nginx,Deploy NGINX Ingress as load balancer"
  ""
  "hello,Deploy hello world service"
  "curl,Validate exposed hello service using curl to LB Ingress"
  ""
  "nfs-host,Create /data/nfs1 on Ansible orchestrator host"
  "nfs-sc,Install nfs dynamic provisioner and StorageClass"
  ""
  "mailhog,Deploy in-cluster SMTP server for mail alerts"
  "prometheus,Deploy community kube-prometheus-stack with helm"
)

function showMenu() {
  echo ""
  echo ""
  echo "==========================================================================="
  echo " MAIN MENU"
  echo "==========================================================================="
  echo ""
  
  for menu_item in "${menu_items[@]}"; do
    # skip empty lines
    [ -n "$menu_item" ] || { printf "\n"; continue; }

    menu_id=$(echo $menu_item | cut -d, -f1)
    # eval done so that embedded variables get evaluated (e.g. MYKUBECONFIG)
    label=$(eval echo $menu_item | cut -d, -f2-)
    printf "%-16s %-60s %-12s\n" "$menu_id" "$label" "${done_status[$menu_id]}"

  done
  echo ""
} # showMenu


GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'
NF='\033[0m'
function echoGreen() {
  echo -e "${GREEN}$1${NC}"
}
function echoRed() {
  echo -e "${RED}$1${NC}"
}
function echoYellow() {
  echo -e "${YELLOW}$1${NC}"
}

function ensure_binary() {
  binary="$1"
  install_instructions="$2"
  binpath=$(which $binary)
  if [ -z "$binpath" ]; then
    echo "ERROR you must install $binary before running this wizard"
    echo "$install_instructions"
    exit 1
  fi
}

function check_prerequisites() {

  # make sure binaries are installed 
  ensure_binary kubectl "install https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/"
  ensure_binary terraform "install https://fabianlee.org/2021/05/30/terraform-installing-terraform-manually-on-ubuntu/"
  ensure_binary ansible "install https://fabianlee.org/2021/05/31/ansible-installing-the-latest-ansible-on-ubuntu/"
  ensure_binary make "run 'sudo apt install make'"

  # show binary versions
  # on apt, can be upgraded with 'sudo apt install --only-upgrade google-cloud-sdk -y'
  kubectl version --short 2>/dev/null
  terraform --version | head -n 1
  ansible --version | head -n1
  make --version | head -n1

  echo ""

} # check_prerequisites


###### MAIN ###########################################


# if kubeconfig optionally specified on command line
[ -n "$KUBECONFIG" ] || export KUBECONFIG="/tmp/kubeadm-kubeconfig"

check_prerequisites "$@"

# loop where user can select menu items
lastAnswer=""
answer=""
while [ 1 == 1 ]; do
  showMenu
  test -t 0
  if [ ! -z $lastAnswer ]; then echo "Last action was '${lastAnswer}'"; fi
  read -p "Which action (q to quit) ? " answer
  echo ""

  case $answer in

    prereq)
      set -x
      ./install_requirements.sh
      retVal=$?
      set +x

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;

    sshkeypair)
      cd tf-libvirt
      set -x
      if [ ! -f id_rsa ]; then
        ssh-keygen -t rsa -b 4096 -f id_rsa -C tf-libvirt -N "" -q
      else
        echoGreen "SKIP SSH keypair for guest VMs already exists"
      fi
      retVal=$?
      cd ..
      set +x

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;

    tf)
      cd tf-libvirt
      set -x
      make
      retVal=$?
      set +x 
      cd ..

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;

    ansibleping)
      set -x
      ansible -m ping all
      retVal=$?
      set +x 

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;

    ssh)
      retVal=0
      echo "1. control1"
      echo "2. worker1"
      echo "3. worker2"
      echo ""
      read -p "ssh into which jumpbox ? " which_guest

      case $which_guest in
        1) guestvm=192.168.122.217
        ;;
        2) guestvm=192.168.122.218
        ;;
        3) guestvm=192.168.122.219
        ;;
        *)
          echo "ERROR did not recognize which $which_guest, valid choices 1-3"
          retVal=1
        ;;
      esac

      set -x
      ssh -i tf-libvirt/id_rsa ubuntu@${guestvm}
      retVal=$?
      set +x

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;


    kubeadm-prep)
      set -x
      ansible-playbook playbook_kubeadm_prep.yml
      retVal=$?
      set +x 

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;
    kubeadm-control)
      set -x
      ansible-playbook playbook_kubeadm_controlplane.yml
      retVal=$?
      set +x 

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;
    kubeadm-workers)
      set -x
      ansible-playbook playbook_kubeadm_workers.yml
      retVal=$?
      set +x 

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;


    metallb)
      set -x
      ansible-playbook playbook_metallb.yml
      retVal=$?
      set +x 

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;
    certs)
      set -x
      ansible-playbook playbook_certs.yml
      retVal=$?
      set +x 

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;
    nginx)
      set -x
      ansible-playbook playbook_nginx.yml
      retVal=$?
      set +x 

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;


    hello)
      set -x
      ansible-playbook playbook_deploy_myhello.yml
      retVal=$?
      set +x 

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;
    curl)
      lb_ip=$(KUBECONFIG=/tmp/kubeadm-kubeconfig kubectl get service -n ingress-nginx ingress-nginx-controller -o jsonpath="{.status.loadBalancer.ingress[].ip}")
      echo "load balancer IP: $lb_ip"
      set -x
      curl -k --resolve kubeadm.local:443:${lb_ip} https://kubeadm.local:443/myhello/
      retVal=$?
      set +x 

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;

    nfs-host)
      set -x
      prereq/create_host_nfs.sh
      retVal=$?
      set +x 

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;
    nfs-sc)
      set -x
      ansible-playbook playbook_nfs_helm_sc.yml
      retVal=$?
      set +x 

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;

    mailhog)
      set -x
      ansible-playbook playbook_mailhog.yml
      retVal=$?
      set +x 

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;
    prometheus)
      set -x
      ansible-playbook playbook_prometheus_helm.yml
      retVal=$?
      set +x 

      [ $retVal -eq 0 ] && done_status[$answer]="OK" || done_status[$answer]="ERR"
      ;;

    q|quit|0)
      echo "QUITTING"
      exit 0;;
    *)
      echoRed "ERROR that is not one of the options, $answer";;
  esac

  lastAnswer=$answer
  echo "press <ENTER> to continue..."
  read -p "" foo

done




