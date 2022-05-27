## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_objectstorage_namespace" "ns" {
    compartment_id = var.compartment_ocid
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_vnic_attachments" "ScanInstance_primaryvnic_attach" {
  availability_domain = var.availability_domain_name
  compartment_id      = oci_identity_compartment.ScanCompart.id
  instance_id         = oci_core_instance.ScanInstance.id
}

data "oci_core_vnic" "ScanInstance_primaryvnic" {
  vnic_id = data.oci_core_vnic_attachments.ScanInstance_primaryvnic_attach.vnic_attachments.0.vnic_id
}

data "oci_identity_region_subscriptions" "home_region_subscriptions" {
    tenancy_id = var.tenancy_ocid

    filter {
      name   = "is_home_region"
      values = [true]
    }
}

data "oci_core_images" "InstanceImageOCID" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.instance_shape

/* A filter is not required, we get the right image without it by having instance_os = Oracle Linux Cloud Developer

  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-Cloud-Developer[^G]*$"]
    regex = true
  }

  */
}