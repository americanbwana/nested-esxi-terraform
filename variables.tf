variable "cluster" { default = "vcf-w1c1" }
variable "vsphere_resource_pool" { default = "Compute-ResourcePool" }
 
variable "vsphere_user" { default = "administrator@vsphere.local"}
variable "vsphere_password" { default = "VMware1!"}
variable "vsphere_server" { default = "vcf-w1-vc.corp.local"}
variable "vsphere_datastore" { default = "vcf-w1c1-vsan" }

variable "vsphere_datacenter" { default = "vcf-w1-dc" }

variable "vsphere_cluster" { default = "vcf-w1c1"}

variable "vsphere_network" { default = "VMnetwork"}

variable "vsphere_host" { default = "vcf-esxi1.corp.local"}

# OVF guestinfo
variable "hostname" {}
variable "ipaddress" {}
variable "netmask" { default = "255.255.255.0"} 
variable "gateway" {}
variable "dnsServer" {}
variable "dnsDomain" { default = "corp.local"}
variable "ntpServer" { default = "0.north-america.pool.ntp.org"}
variable "esxiRootPassword" { default = "VMware1!" }
variable "enableSsh" { default = true }

