#!/bin/bash
#
# ssh into KVM guest VM using ssh key
#
octet=${1:-217}
set -x
ssh -i tf-libvirt/id_rsa ubuntu@192.168.122.${octet}
