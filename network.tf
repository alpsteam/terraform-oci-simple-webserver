
resource "oci_core_vcn" "personal_server_vcn" {
  cidr_block      = "10.0.0.0/16"
  compartment_id  = "${var.compartment_ocid}"
  display_name    = "personal_server_vcn"
}

resource "oci_core_internet_gateway" "personal_server_igw" {
  compartment_id  = "${var.compartment_ocid}"
  vcn_id          = "${oci_core_vcn.personal_server_vcn.id}"
  display_name    = "personal_server_igw"
}

resource "oci_core_route_table" "personal_server_rt" {
  compartment_id  = "${var.compartment_ocid}"
  vcn_id          = "${oci_core_vcn.personal_server_vcn.id}"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.personal_server_igw.id}"
  }

  display_name    = "personal_server_rt"
}

resource "oci_core_security_list" "personal_server_sl" {
  compartment_id  = "${var.compartment_ocid}"
  vcn_id          = "${oci_core_vcn.personal_server_vcn.id}"

  egress_security_rules { 
    destination = "0.0.0.0/0"
    protocol = "all" 
  }
  
  ingress_security_rules {
    protocol = "6"
    source = "0.0.0.0/0"
    tcp_options { 
      max = 22
      min = 22
    }
  }

  ingress_security_rules { 
    protocol = "6"
    source = "0.0.0.0/0" 
    tcp_options { 
      max = 80
      min = 80
    }
  }
  display_name   = "personal_server_sl"
}

resource "oci_core_subnet" "personal_server_sn" {
  compartment_id    = "${var.compartment_ocid}"
  vcn_id            = "${oci_core_vcn.personal_server_vcn.id}"
  cidr_block        = "10.0.1.0/24"
  security_list_ids = ["${oci_core_security_list.personal_server_sl.id}"]
  route_table_id    = "${oci_core_route_table.personal_server_rt.id}"
  display_name    = "personal_server_sn"
  availability_domain = "${local.ad_1}"
}