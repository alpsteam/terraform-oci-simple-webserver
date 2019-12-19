data "oci_identity_availability_domains" "ads" {
  compartment_id = "${var.tenancy_ocid}"
}

locals {
  ad_1 = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0], "name")}"
}

data "oci_core_images" "personal_server_image" {
  compartment_id    = "${var.compartment_ocid}"
  operating_system  = "Oracle Linux"
  shape             = "VM.Standard.E2.1"
}

locals {
  oracle_linux = "${lookup(data.oci_core_images.personal_server_image.images[0],"id")}"
}

resource "tls_private_key" "public_private_key_pair" {
  algorithm   = "RSA"
}

resource "oci_core_instance" "personal_server_vm_instance" {
  compartment_id        = var.compartment_ocid
  availability_domain   = local.ad_1
  shape                 = "VM.Standard.E2.1"

  source_details {
    source_id     = local.oracle_linux
    source_type   = "image"
  }
  create_vnic_details {
    subnet_id         = oci_core_subnet.personal_server_sn.id
    display_name      = "primary_vnic"
    assign_public_ip  = true
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
  timeouts {
    create = "5m"
  }
  display_name = "personal_server_vm_instance"
}

resource "null_resource" "remote-exec" {
  depends_on = [oci_core_instance.personal_server_vm_instance]
  
  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = oci_core_instance.personal_server_vm_instance.public_ip
      user        = "opc"
      private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
  
    inline = [
      "sudo /bin/yum install -y nginx",
      "sudo /bin/systemctl start nginx",
      "sudo /bin/firewall-offline-cmd --add-port=80/tcp",
      "sudo /bin/systemctl restart firewalld",
      "sudo cp /usr/share/nginx/html/index.html /usr/share/nginx/html/index.original.html",
      "sudo chmod 777 /usr/share/nginx/html/index.html",
      "echo '<html><h1>Max Compute Instance</h1></html>' > /usr/share/nginx/html/index.html",
    ]
  }
}