#!/bin/bash

# Array of VM names
vms=("GOAD-DC01" "GOAD-DC02" "GOAD-DC03" "GOAD-SRV02" "GOAD-SRV03")

# Function to check if a VM exists
vm_exists() {
  vboxmanage list vms | grep -q "\"$1\""
}

# Function to start a VM
start_vm() {
  if [ "$1" = "all" ]; then
    start_all_vms
  else
    if vm_exists "$1"; then
      echo "Starting VM: $1"
      vboxmanage startvm "$1" --type headless
    else
      echo "VM $1 does not exist."
    fi
  fi
}

# Function to stop a VM
stop_vm() {
  if [ "$1" = "all" ]; then
    stop_all_vms
  else
    if vm_exists "$1"; then
      echo "Stopping VM: $1"
      vboxmanage controlvm "$1" acpipowerbutton
    else
      echo "VM $1 does not exist."
    fi
  fi
}

# Function to restart a VM
restart_vm() {
  if [ "$1" = "all" ]; then
    restart_all_vms
  else
    if vm_exists "$1"; then
      echo "Restarting VM: $1"
      vboxmanage controlvm "$1" reset
    else
      echo "VM $1 does not exist."
    fi
  fi
}

# Function to display detailed info of a VM
vm_info() {
  vm_name="$1"
  if vm_exists "$vm_name"; then
    echo "Information for VM: $vm_name"
    echo "-----------------------------------------"
    echo "State:"
    vboxmanage showvminfo "$vm_name" --machinereadable | grep "^VMState="
    echo "Guest OS:"
    vboxmanage showvminfo "$vm_name" --machinereadable | grep "^GuestOSType="
    echo "Memory size (MB):"
    vboxmanage showvminfo "$vm_name" --machinereadable | grep "^memory="
    echo "Number of CPUs:"
    vboxmanage showvminfo "$vm_name" --machinereadable | grep "^cpus="
    echo "-----------------------------------------"
    echo "IP addresses:"
    vboxmanage guestproperty enumerate "$vm_name" | grep IP
  else
    echo "VM $vm_name does not exist."
  fi
}

# Function to start all VMs
start_all_vms() {
  cd ad/GOAD/providers/virtualbox || { echo "Directory not found"; exit 1; }
  for vm in "${vms[@]}"; do
    start_vm "$vm" &
  done
  wait
  echo "All VMs are started."
}

# Function to stop all VMs
stop_all_vms() {
  for vm in "${vms[@]}"; do
    stop_vm "$vm" &
  done
  wait
  echo "All VMs are stopped."
}

# Function to restart all VMs
restart_all_vms() {
  for vm in "${vms[@]}"; do
    restart_vm "$vm" &
  done
  wait
  echo "All VMs are restarted."
}

# Function to display info for all VMs or specific VM
status_vm() {
  if [ -z "$1" ]; then
    echo "Please provide a VM name or 'all' for all VMs."
    exit 1
  fi

  if [ "$1" = "all" ]; then
    for vm in "${vms[@]}"; do
      vm_info "$vm"
      echo "========================================="
    done
  else
    vm_info "$1"
  fi
}

# Check for user input
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: $0 {start|stop|restart|status} [VM_NAME|all]"
  exit 1
fi

# Perform action based on user input
case "$1" in
  start)
    start_vm "$2"
    ;;
  stop)
    stop_vm "$2"
    ;;
  restart)
    restart_vm "$2"
    ;;
  status)
    status_vm "$2"
    ;;
  *)
    echo "Invalid option: $1"
    echo "Usage: $0 {start|stop|restart|status} [VM_NAME|all]"
    exit 1
    ;;
esac
