provider "oci" {
  version          = ">= 3.0.0"
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
  private_key_path = var.private_key_path
}
