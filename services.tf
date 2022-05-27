## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_events_rule" "ScanEventRule" { 
  #Required
  display_name    = "ScanEventRule"
  compartment_id  = oci_identity_compartment.ScanCompart.id
  is_enabled      = true  
  condition       = "{\"eventType\": \"com.oraclecloud.objectstorage.createobject\"}"
  actions {
    #Required
    actions {
      #Required
      action_type = "OSS"
      is_enabled  = true

      #Optional
      stream_id   = oci_streaming_stream.ScanStream.id
    }
  }
  defined_tags = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_streaming_stream" "ScanStream" {
    #Required
    name       = "ScanStream"
    partitions = 1

    #Optional
    compartment_id = oci_identity_compartment.ScanCompart.id
    defined_tags = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
