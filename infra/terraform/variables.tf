variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}
variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}
variable "server_type" {
  default = "cx22"
}
variable "location" {
  default = "nbg1"
}
