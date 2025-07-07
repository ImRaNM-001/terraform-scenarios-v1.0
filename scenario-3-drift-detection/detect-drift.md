# Terraform Drift Detection

## What is Drift Detection?

Terraform drift detection is the process of identifying discrepancies between your Terraform configuration, the state file, and the actual infrastructure resources. Drift occurs when someone manually modifies infrastructure resources outside of Terraform, causing the real-world state to diverge from what Terraform expects.

## How Terraform Commands Help with Drift Detection

- **`terraform refresh`**: Updates the state file with the current real-world state of resources
- **`terraform plan`**: Compares the configuration with the state file to show what changes would be applied
- **`terraform plan -refresh-only`**: Shows what changes would be made to the state file to match real infrastructure

```sh
# [Sample Output] --> No changes. Your infrastructure still matches the configuration.

# --> Terraform has checked that the real remote objects still match the result of your most recent changes, and found no differences.
```

## Methods for Drift Detection

### Method 1: Scheduled Refresh Approach

**Implementation**: Use `terraform refresh` in a cron job or CI/CD pipeline

```bash
# Example cron job (runs every hour)
0 * * * * cd /path/to/terraform && terraform refresh
```

**Pros**:
- Simple to implement
- Automatically updates state file
- Can be automated

**Cons**:
- `terraform refresh` is deprecated in newer Terraform versions
- Only updates state, doesn't notify about drift
- May mask configuration drift issues

### Method 2: Plan-Based Detection (Terraform Team Endorsed)

**Implementation**: Use `terraform plan` to detect drift without modifying state

```bash
# Detect drift without changing state
terraform plan -detailed-exitcode

# Exit codes:
# 0 = No changes
# 1 = Error
# 2 = Changes detected (potential drift)

# Example: [Sample Output] -->

    # (3 unchanged blocks hidden)
        }
        # module.security-group.aws_security_group.<SG_GROUP_NAME> will be updated in-place
      #   ~ resource "aws_security_group" "alb_sg" {
      #         id                     = "sg-047xxxx98a6"
      #       ~ ingress                = [
      #           - {
      #               - cidr_blocks      = [
      #                   - "0.0.0.0/0",
      #                 ]
      #               - from_port        = 8090          
      #               - ipv6_cidr_blocks = []
      #               - prefix_list_ids  = []
      #               - protocol         = "tcp"
      #               - security_groups  = []
      #               - self             = false
      #               - to_port          = 8090        # this was changed in UI console manually & detected
      #                 # (1 unchanged attribute hidden)
      #             },
      #             # (1 unchanged elements hidden)
      #         ]
      #         name                   = "alb security group"
      #         tags                   = {
      #             "Name" = "alb_sg"
      #         }
      #         # (8 unchanged attributes hidden)
      #     }
      
      # Plan: 0 to add, 1 to change, 0 to destroy.
```

**Pros**:
- Recommended by HashiCorp/Terraform team
- Doesn't modify state file
- Clear indication of drift through exit codes
- Can be integrated into monitoring systems

### Method 3: Cloud-Native Monitoring (Best Practice)

**A) Audit Log Monitoring**:
- **AWS**: CloudTrail events → CloudWatch → Lambda → SNS notifications
- **Azure**: Activity Logs → Logic Apps/Functions → Alert notifications
- **GCP**: Cloud Audit Logs → Cloud Functions → Pub/Sub notifications

**B) Preventive Measures**:
- Implement strict IAM/RBAC policies
- Use service accounts with minimal permissions
- Enable MFA for console access
- Implement resource tagging for Terraform-managed resources

## Terraform Team Recommendations

### What HashiCorp Endorses:

1. **Use `terraform plan -refresh-only`** instead of deprecated `terraform refresh`
2. **Implement drift detection in CI/CD pipelines** using plan exit codes
3. **Use Terraform Cloud/Enterprise** for centralized state management and drift detection
4. **Adopt policy-as-code** using Sentinel or OPA for compliance

### Modern Approach (Terraform 0.15.4+):

```bash
# Recommended drift detection workflow
terraform plan -refresh-only -out=drift.tfplan
terraform show -json drift.tfplan | jq '.resource_drift'
```

## Automated Drift Detection Pipeline

### Example CI/CD Integration:

```yaml
# GitHub Actions example
name: Drift Detection
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours

jobs:
  detect-drift:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Detect Drift
        run: |
          terraform init
          terraform plan -detailed-exitcode
        continue-on-error: true
      - name: Notify on Drift
        if: ${{ steps.detect-drift.outputs.exitcode == '2' }}
        run: echo "Drift detected! Sending notification..."
```

## Best Practices Summary

1. **Use `terraform plan` with exit codes** for drift detection
2. **Implement cloud-native monitoring** using audit logs
3. **Apply principle of least privilege** for infrastructure access
4. **Use Terraform Cloud/Enterprise** for advanced drift detection features
5. **Integrate drift detection into CI/CD pipelines**
6. **Tag all Terraform-managed resources** for easier identification
7. **Regularly review and update IAM policies**

## Tools and Services

- **Terraform Cloud**: Built-in drift detection and notifications
- **Terragrunt**: Wrapper tool with drift detection capabilities
- **Checkov**: Static analysis tool that can detect policy violations
- **Cloud-specific tools**: AWS Config, Azure Policy, GCP Security Command Center