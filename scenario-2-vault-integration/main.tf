# retrieve data/info from data source(ex: hashicorp vault) Deprecated warning: vault_kv_secret_v2 
data "vault_kv_secret_v2" "vault-data" {
  mount = var.vault_secret_mount
  name = var.vault_secret_path
}

# Create S3 bucket placing the secret
resource "aws_s3_bucket" "vault-intgr-secret-bucket" {
  bucket = data.vault_kv_secret_v2.vault-data.data[var.vault_secret_username]
  tags = {
    Name = "S3-Vault-Intgr-Bucket"
    # Secret = 
  }
}

