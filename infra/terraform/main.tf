terraform {
  required_providers {
    hcloud = { source = "hetznercloud/hcloud", version = "~> 1.47" }
  }
}
provider "hcloud" { token = var.hcloud_token }

resource "hcloud_ssh_key" "firststep" {
  name       = "firststep-deploy"
  public_key = file(var.ssh_public_key_path)
}
resource "hcloud_server" "firststep" {
  name        = "firststep-prod"
  server_type = var.server_type
  image       = "debian-12"
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.firststep.id]
  labels      = { project = "firststep" }
}
output "server_ip" { value = hcloud_server.firststep.ipv4_address }
