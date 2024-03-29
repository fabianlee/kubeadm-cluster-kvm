THISDIR := $(notdir $(CURDIR))
PROJECT := $(THISDIR)
# system connection, in case LIBVIRT_DEFAULT_URI env var is not defined
LIBVIRT_URI := qemu:///system
TF := terraform

apply: init libvirt-prereq
	$(TF) apply -auto-approve

init: create-keypair
	$(TF) init

destroy: virsh-snapshot-delete
	$(TF) destroy -auto-approve
	./clean-known-hosts.sh
	rm -fr *tfstate* .terraform.lock.hcl

## create public/private keypair for ssh
create-keypair:
	# skips if file already exists
	[ -f id_rsa ] || ssh-keygen -t rsa -b 4096 -f id_rsa -C $(PROJECT) -N "" -q

refresh:
	$(TF) refresh
	$(TF) output

libvirt-prereq:
	@echo Making sure libvirt default disk pool and network exist
	virsh --connect $(LIBVIRT_URI) pool-info default
	virsh --connect $(LIBVIRT_URI) net-info default

	@echo Making sure virtual bridge 'br0' exists on host
        @echo https://fabianlee.org/2019/04/01/kvm-creating-a-bridged-network-with-netplan-on-ubuntu-bionic/
	ip a show br0
	@echo Making sure libvirt 'host-bridge' exists that uses 'br0' host bridge
	virsh --connect $(LIBVIRT_URI) net-info host-bridge

libvirt-pool:
	$(eval POOLDIR=$(shell virsh --connect ${LIBVIRT_URI} pool-dumpxml default | grep -E "<path>.*</path>" | grep -Po "(?<=\>)[^<]+"))
	@echo POOLDIR is $(POOLDIR)

## validate syntax of cloud_init
validate-cloud-config:
	cloud-init devel schema --config-file cloud_init.cfg

virsh-snapshot-create: virsh-stop-all
	sleep 5
	virsh snapshot-create-as control1-192.168.122.217 --name adv-test
	virsh snapshot-create-as worker1-192.168.122.218 --name adv-test
	virsh snapshot-create-as worker2-192.168.122.219 --name adv-test

virsh-snapshot-delete: virsh-stop-all
	sleep 5
	virsh snapshot-delete control1-192.168.122.217 adv-test || true
	virsh snapshot-delete worker1-192.168.122.218 adv-test || true
	virsh snapshot-delete worker2-192.168.122.219 adv-test || true

virsh-snapshot-revert: virsh-stop-all
	sleep 5
	virsh snapshot-revert control1-192.168.122.217 --snapshotname adv-test
	virsh snapshot-revert worker1-192.168.122.218 --snapshotname adv-test
	virsh snapshot-revert worker2-192.168.122.219 --snapshotname adv-test
	virsh start control1-192.168.122.217 || true
	virsh start worker1-192.168.122.218 || true
	virsh start worker2-192.168.122.219 || true

virsh-start-all:
	echo "Starting all VMs..."
	virsh start control1-192.168.122.217 || true
	virsh start worker1-192.168.122.218 || true
	virsh start worker2-192.168.122.219 || true
virsh-stop-all:
	echo "Stopping all VMs..."
	virsh destroy control1-192.168.122.217 || true
	virsh destroy worker1-192.168.122.218 || true
	virsh destroy worker2-192.168.122.219 || true
