## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "tenancy_ocid" {}
#variable "private_key_path" {}
#variable "fingerprint" {}
#variable "user_ocid"{}
variable "compartment_ocid" {}
variable "region" {}
variable "availability_domain_name" {}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.2"
}

variable "ScanVCN_CIDR" { 
  default = "172.16.0.0/16"
}

variable "Scan_subnet_public_CIDR" {
  default = "172.16.0.0/24"
}

variable "instance_shape" {
  default = "VM.Standard.E4.Flex"
}

variable "instance_flex_shape_ocpus" {
    default = 1
}

variable "instance_flex_shape_memory" {
    default = 10
}

variable "ssh_public_key" {
  default = ""
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex"
  ]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_node_shape = contains(local.compute_flexible_shapes, var.instance_shape)
}

variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux Cloud Developer"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "9"
}