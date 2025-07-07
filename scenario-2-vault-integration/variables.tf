variable "region" {
  description = "AWS region for resources"
}

variable "ec2_public_ip" {
  description = "EC2 Public IP address"
}

variable "vault_role_id" {
  description = "Role ID for hashicorp vault approle"
}

variable "vault_secret_id" {
  description = "Secret ID for hashicorp vault secret"
}

variable "vault_secret_mount" {
  description = "Mount for the vault secret"
}

variable "vault_secret_path" {
  description = "Path name for the vault secret"
}

variable "vault_secret_username" {
  description = "Username for the vault secret"
}
