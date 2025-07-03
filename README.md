# terraform-scenarios-v1.0

This repository demonstrates how to migrate existing manually created AWS resources into Terraform management using the import workflow. The process involves generating Terraform configuration from existing infrastructure, importing the resource state, and then managing it through Terraform going forward.

## Why use Terraform Import?
Terraform import allows you to bring existing resources under Terraform management without recreating them. This is useful for infrastructure that was provisioned manually or by other tools, enabling you to manage everything as code and benefit from Terraform’s automation and version control.

## Workflow Steps

### 1. Generate Terraform Configuration from Existing Resource
```sh
terraform plan -generate-config-out="generated_resources.tf"
```
- **What it does:**
  - This command inspects your existing infrastructure and generates a Terraform configuration file (`generated_resources.tf`) that describes the detected resources.
  - It helps you quickly bootstrap your Terraform codebase with the current state of your resources.

### 2. Import the Resource State into Terraform
```sh
terraform import aws_instance.<resource_name_in_tf> <ec2_instance_id>
# Example:
terraform import aws_instance.scenario-1-import i-0042504d109b03512
```
- **What it does:**
  - This command tells Terraform to associate the existing AWS EC2 instance (identified by `<instance-id>`) with the resource block `aws_instance.scenario-1-import` in your configuration.
  
  - It updates the Terraform state file so Terraform knows about this resource and can manage it going forward.

### 3. Review and Plan Further Changes
```sh
terraform plan
```
- **What it does:**
  - This command shows you what changes Terraform would make if you applied your configuration.
  - After importing, it’s important to run `terraform plan` to verify that your configuration matches the actual resource state and to see if any changes would be made.

---

- The import process does not automatically create configuration files for you (except when using `-generate-config-out`). You should review and refine the generated configuration, and move it into your main Terraform files for ongoing management.
- This workflow ensures that your manually created resources are now fully managed by Terraform, enabling infrastructure as code best practices.
