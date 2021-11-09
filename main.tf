terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.0.2"
    }
  }
  required_version = ">= 1.0.10"
}

provider "vsphere" {
# will use TF_VAR
#   user           = var.vsphere_user
#   password       = var.vsphere_password
#   vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

## Remote OVF/OVA Source
data "vsphere_ovf_vm_template" "ovfRemote" {
  name              = "foo"
  disk_provisioning = "thin"
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  remote_ovf_url    = "https://download3.vmware.com/software/vmw-tools/nested-esxi/Nested_ESXi7.0u3_Appliance_Template_v1.ova"
  ovf_network_map   = {
    "VM Network" : data.vsphere_network.network.id
  }
}


## Deployment of VM from Remote OVF
resource "vsphere_virtual_machine" "vmFromRemoteOvf" {
  name                  = "Nested-ESXi-7.0-Terraform-Deploy-1"
  resource_pool_id      = data.vsphere_resource_pool.pool.id
  datastore_id          = data.vsphere_datastore.datastore.id
  datacenter_id         = data.vsphere_datacenter.datacenter.id
  host_system_id        = data.vsphere_host.host.id
  num_cpus              = data.vsphere_ovf_vm_template.ovfRemote.num_cpus
  num_cores_per_socket  = data.vsphere_ovf_vm_template.ovfRemote.num_cores_per_socket
  memory                = data.vsphere_ovf_vm_template.ovfRemote.memory
  guest_id              = data.vsphere_ovf_vm_template.ovfRemote.guest_id
  nested_hv_enabled     = data.vsphere_ovf_vm_template.ovfRemote.nested_hv_enabled
  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.ovfRemote.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout = 0

  ovf_deploy {
    allow_unverified_ssl_cert = false
    local_ovf_path            = data.vsphere_ovf_vm_template.ovfRemote.remote_ovf_url
    disk_provisioning         = data.vsphere_ovf_vm_template.ovfRemote.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.ovfRemote.ovf_network_map
  }

  vapp {
    properties = {
      "guestinfo.hostname" = var.hostname,
      "guestinfo.ipaddress" = var.ipaddress,
      "guestinfo.netmask" = var.netmask,
      "guestinfo.gateway" = var.gateway,
      "guestinfo.dns" = var.dnsServer,
      "guestinfo.domain" = var.dnsDomain,
      "guestinfo.ntp" = var.ntpServer,
      "guestinfo.password" = var.esxiRootPassword,
      "guestinfo.ssh" = var.enableSsh
    }
  }

  lifecycle {
    ignore_changes = [
      annotation,
      disk[0].io_share_count,
      disk[1].io_share_count,
      disk[2].io_share_count,
      vapp[0].properties,
    ]
  }
}
