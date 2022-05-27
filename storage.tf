## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_objectstorage_bucket" "checkinobj" { 
    #Required
    compartment_id = oci_identity_compartment.ScanCompart.id
    name           = "checkinobj"
    namespace      = data.oci_objectstorage_namespace.ns.namespace

    #Optional
    object_events_enabled = true
    defined_tags = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}

resource "oci_objectstorage_bucket" "quarantine" {
    #Required
    compartment_id = oci_identity_compartment.ScanCompart.id
    name           = "quarantine"
    namespace      = data.oci_objectstorage_namespace.ns.namespace
    defined_tags = {"${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
