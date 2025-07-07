provider "aws" {
  region = var.region
}

# Initialize the Hashicorp Vault provider and authenticate to it
provider "vault" {
  address = var.ec2_public_ip
  skip_child_token = true
  
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = var.vault_role_id
      secret_id = var.vault_secret_id
    }
  }
  
}