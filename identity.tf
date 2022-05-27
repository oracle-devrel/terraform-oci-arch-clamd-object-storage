## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_identity_compartment" "ScanCompart" {
  provider = oci.homeregion  
  description = "Scan"
  name = "Scan"
  compartment_id = var.compartment_ocid
}

resource "oci_identity_dynamic_group" "ScanDynGroup" {
  provider = oci.homeregion  
  depends_on = [oci_core_instance.ScanInstance]
  compartment_id = var.tenancy_ocid
  description = "ScanDynGroup"
  matching_rule = join("",["ANY { instance.id = '" , oci_core_instance.ScanInstance.id , "' }"])
  name = "ScanDynGroup-${random_id.tag.hex}"
}

resource "oci_identity_policy" "ScanPolicy1" {
  provider = oci.homeregion  
  depends_on = [oci_identity_dynamic_group.ScanDynGroup]
  compartment_id = var.tenancy_ocid
  description = "ScanPolicy"
  name = "ScanPolicy-${random_id.tag.hex}"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.ScanDynGroup.name} to manage buckets in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.ScanDynGroup.name} to manage objects in tenancy",
    format("Allow service objectstorage-%s to manage object-family in tenancy", var.region)
  ]
}

resource "oci_identity_policy" "ScanPolicy2" {
  provider = oci.homeregion  
  depends_on = [oci_identity_dynamic_group.ScanDynGroup]
  compartment_id = oci_identity_compartment.ScanCompart.id
  description = "ScanPolicy"
  name = "ScanPolicy-${random_id.tag.hex}"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.ScanDynGroup.name} to manage stream-family in compartment ${oci_identity_compartment.ScanCompart.name}"
  ]
}