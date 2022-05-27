resource "null_resource" "ScanInstance-config" {
  depends_on = [oci_core_instance.ScanInstance]

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.ScanInstance_primaryvnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "scripts/bootstrap.sh"
    destination = "/home/opc/bootstrap.sh"
  }


  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.ScanInstance_primaryvnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"  
    }
    inline = [
     "chmod +x /home/opc/bootstrap.sh",
     "sudo /home/opc/bootstrap.sh"
    ]
  }

}

