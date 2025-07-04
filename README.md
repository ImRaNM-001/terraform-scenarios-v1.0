# terraform-scenarios-v1.0

This repository demonstrates how to migrate existing manually created AWS resources into Terraform management using the import workflow. The process involves generating Terraform configuration from existing infrastructure, importing the resource state, and then managing it through Terraform going forward.

## **1. Resource-Migration**:

## Why use Terraform Import?
Terraform import allows you to bring existing resources under Terraform management without recreating them. This is useful for infrastructure that was provisioned manually or by other tools, enabling you to manage everything as code and benefit from Terraform’s automation and version control.

## Workflow Steps

### 1. Initialize the Terraform project at the root directory (where **main.tf** is located)
```sh
terraform init
```

### 2. Generate Terraform Configuration from Existing Resource
```sh
terraform plan -generate-config-out="generated_resources.tf"
```
- **What it does:**
  - This command inspects your existing infrastructure and generates a Terraform configuration file (`generated_resources.tf`) that describes the detected resources.

  - It helps you quickly bootstrap your Terraform codebase with the current state of your resources.

### 3. Import the Resource State into Terraform
```sh
terraform import aws_instance.<resource_name_in_tf> <ec2_instance_id>

# Example:
terraform import aws_instance.scenario-1-import i-0a71605ac6302abfb
```
- **What it does:**
  - This command tells Terraform to associate the existing AWS EC2 instance (identified by `<instance-id>`) with the resource block `aws_instance.scenario-1-import` in your configuration.
  
  - It updates the Terraform state file so Terraform knows about this resource and can manage it going forward.

### 4. Review and Plan Further Changes
```sh
terraform plan
```
- **What it does:**
  - This command shows you what changes Terraform would make if you applied your configuration.
  - After importing, it’s important to run `terraform plan` to verify that your configuration matches the actual resource state and to see if any changes would be made.

---

- The import process does not automatically create configuration files for you (except when using `-generate-config-out`). You should review and refine the generated configuration, and move it into your main Terraform files for ongoing management.
- This workflow ensures that your manually created resources are now fully managed by Terraform, enabling infrastructure as code best practices.

---

## **2. Vault-Integration**:

### Install Vault on the EC2 instance

**Step 1:** Install gpg  
```sh
sudo apt update && sudo apt install gpg
```

**Step 2:** Download the signing key to a new keyring  
```sh
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

**Step 3:** Verify the key's fingerprint  
3(a)  
```sh
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
```
3(b)  
```sh
gpg --show-keys --with-fingerprint /usr/share/keyrings/hashicorp-archive-keyring.gpg
```
```
gpg: keybox '/home/ubuntu/.gnupg/pubring.kbx' created
pub   rsa4096 2023-01-10 [SC] [expires: 2028-01-09]
    XXXX XXXX XXXX XXXX 8C8E  XXXX XXXX
uid                      HashiCorp Security (HashiCorp Package Signing) <security+packaging@hashicorp.com>
sub   xxx096 2023-01-10 [S] [expires: 2028-01-09]
```

**Step 4:** Add the HashiCorp repo  
```sh
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```
```
deb [arch=amd64 signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main
```

**Step 5:** Install Vault  
```sh
sudo apt install vault
```

**Step 6:** Start & keep vault running in a terminal  
```sh
vault server -dev -dev-listen-address="0.0.0.0:8200"
```

**Step 7:** Configure Terraform to read the secret from Vault:

7.1: In Vault UI,  
- Click **Enable new engine +**
- Select **generic = KV**
- Path = **vault-secret** (the mount)  
- Click **Enable engine**

7.2: Create secret  
- Path for this secret (section) = **tf-secret-integration**  
- Secret-data section, [NOTE: `password requirements: only lowercase alphanumeric characters and hyphens allowed`]  
  - username: **tf-vault-username**
  - password: **tf-XX-xxX4-0**  
- Save the changes

7.3: Till here, none have access to this secret just self(devops) user.  
Now the objective is to give terraform the access to it, hence we create a role inside the hashicorp vault (similar to IAM role).

7.4: From Vault UI,  
- Click **Access > Enable new method > approle > Enable method**  
  (1 drawback: cannot create any roles or policies via UI)

**Step 8:** Set Vault address  
```sh
export VAULT_ADDR="http://<EC2-PUBLIC-IP>:8200"
# ex: export VAULT_ADDR="http://xx.xxx.000.111:8200"
```

**Step 9:** Enable the AppRole authentication method via CLI  
```sh
vault auth enable approle
```
If you see:
```
Error enabling approle auth: Error making API request.
URL: POST http://xx.xxx.000.111:8200/v1/sys/auth/approle
Code: 400. Errors:
* path is already in use at approle/
```
Check auth list in the vault:
```sh
vault auth list
```
Example output:
```
Path        Type       Accessor                 Description                Version
----        ----       --------                 -----------                -------
approle/    approle    auth_approle_xx3380      n/a                        n/a
token/      token      auth_token_xxxY211       token based credentials    n/a
```

**Step 10:** Create policy via CLI  
```sh
vault policy write terraform - <<EOF
path "*" {
  capabilities = ["list", "read"]
}

path "secrets/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "vault-secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "auth/token/create" {
  capabilities = ["create", "read", "update", "list"]
}
EOF
```
```
Success! Uploaded policy: terraform
```

**Step 11:** Create approle named `terraform` via CLI  
```sh
vault write auth/approle/role/terraform \
    secret_id_ttl=10m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=40 \
    token_policies=terraform
```
```
Success! Data written to: auth/approle/role/terraform
```

**Step 12:** Generate **Role ID**  
```sh
vault read auth/approle/role/<APPROLE_NAME>/role-id
# ex: vault read auth/approle/role/terraform/role-id
```
Example output:
```
Key        Value
---        -----
role_id    xxx-xxx-xxxX-XXXXXX
```

**Step 13:** Generate **Secret ID**  
This is like AWS `access_key` & `secret_access_key` but lives for 10m only, create new every 10 min if timed out  
```sh
vault write -f auth/approle/role/<APPROLE_NAME>/secret-id
# ex: vault write -f auth/approle/role/terraform/secret-id
```
Example output:
```
Key                   Value
---                   -----
secret_id             xxx-xx-xx-xxxXXXX
secret_id_accessor    xxx-xx-xx-xxxXXXX
secret_id_num_uses    40
secret_id_ttl         10m
```

**Step 14:** Write Terraform files in the following files:
- `main.tf`
- `providers.tf`
- `variables.tf`
- `terraform.tfvars`

**Step 15:** Example `terraform.tfvars` values:
```hcl
region = "ap-south-1"

ec2_public_ip = "http://xx.xxx.000.111:8200"

vault_role_id = "xxx-xx-xx-xxx"

vault_secret_id = "xxx-xx-xx-xxxXXXX"

vault_secret_mount = "some-secret"

vault_secret_path = "tf-secret-path"

vault_secret_username = "tf-some-username"
```

**Step 16:** Check available resources  
Run this to see what Vault resources are available:
```sh
terraform providers schema -json | jq '.provider_schemas."registry.terraform.io/hashicorp/vault".resource_schemas | keys'
```

**Step 17:** Run terraform plan & terraform apply

Finally creates s3 bucket named "tf-XX-xxX4-0"
```sh
aws s3 ls
2025-04-08 12:45:46 bucket-1
2025-04-10 14:06:59 bucket-xyz
2025-07-02 19:49:27 task-3-remote-backend
2025-07-04 17:46:31 tf-XX-xxX4-0
```






















