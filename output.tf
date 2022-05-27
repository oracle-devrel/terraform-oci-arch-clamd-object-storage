## Copyright (c) 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "public-ip-for-compute-instance" { 
  value = oci_core_instance.ScanInstance.public_ip
}

output "private-ip-for-compute-instance" {
  value = oci_core_instance.ScanInstance.private_ip
}
 
output "Streaming-id" {
  value = oci_streaming_stream.ScanStream.id
}

output "Streaming-endpoint" {
  value = oci_streaming_stream.ScanStream.messages_endpoint
}

output "generated_ssh_private_key" {
  value = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}
