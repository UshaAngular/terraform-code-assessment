# Terraform Assessment

This project provisions an AWS environment using Terraform. It creates two S3 buckets, two Lambda functions (for reading from and writing to the buckets), and the necessary IAM roles and policies.

---

## Folder Structure

```
terraform-assessment/
├── lambda_read_outbound.py         # Lambda function: reads from outbound, writes to inbound bucket
├── lambda_write_inbound.py         # Lambda function: writes to outbound bucket (assumed)
├── main.tf                        # Main Terraform configuration
├── variables.tf                   # (Assumed) Variable definitions for bucket names, etc.
```

---

## What This Terraform Code Does

- **Creates two S3 buckets:**  
  - `inbound` bucket (name from `var.inbound_bucket_name`)
  - `outbound` bucket (name from `var.outbound_bucket_name`)

- **Creates an IAM role and policy** for Lambda functions to access S3 and CloudWatch Logs.

- **Packages and deploys two Lambda functions:**  
  - `WriteToInboundbucketFunction` (from `lambda_write_inbound.py`)
  - `ReadFromOutboundbucketFunction` (from `lambda_read_outbound.py`)

- **Sets environment variables** for the Lambda functions to reference the S3 buckets.

---

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and configured
- AWS IAM user with permissions to create S3 buckets, Lambda functions, and IAM roles/policies

---

## Setup Instructions

1. **Clone this repository or copy the files to your workspace.**

2. **Set up your AWS credentials**  
   - Run `aws configure` and enter your Access Key, Secret Key, and region  
   - Or, create `C:\Users\<your-username>\.aws\credentials` and `config` files as described above

3. **Edit `variables.tf`** (if present) to set your bucket names:
    ```hcl
    variable "inbound_bucket_name" {
      default = "your-inbound-bucket-name"
    }
    variable "outbound_bucket_name" {
      default = "your-outbound-bucket-name"
    }
    ```

4. **Initialize Terraform:**
    ```
    terraform init
    ```

5. **Apply the configuration:**
    ```
    terraform apply
    ```
    - Review the plan and type `yes` to proceed.

---

## Assumptions

- You have created and configured your AWS credentials with sufficient permissions.
- The Lambda function code (`lambda_read_outbound.py` and `lambda_write_inbound.py`) is present in the root of the project.
- The `variables.tf` file exists and defines `inbound_bucket_name` and `outbound_bucket_name`.
- The IAM user running Terraform has permissions for:
  - S3: `s3:CreateBucket`, `s3:PutObject`, `s3:GetObject`, `s3:DeleteBucket`
  - IAM: `iam:CreateRole`, `iam:PutRolePolicy`, `iam:AttachRolePolicy`, `iam:PassRole`
  - Lambda: `lambda:*`
  - CloudWatch Logs: `logs:*`
- The Lambda functions are compatible with Python 3.12 runtime.

## Further enhancements in future
later this code can be further enhanced to process the file in outbound and write to inbound bucket after any fie processing logic is performed.
Trigger the Lambda only when a new file is uploaded to the outbound bucket, ensuring each file is processed once.
To persist state, we can use DynamoDB, S3 object metadata, or S3 event-driven design. Lambda itself cannot remember state between runs.
---

## Troubleshooting

- **Access Denied Errors:**  
  Ensure your IAM user has the required permissions (see above).

- **Credentials Not Found:**  
  Make sure your AWS credentials are set up correctly in `~/.aws/credentials` or via environment variables.

- **Lambda Packaging:**  
  The `archive_file` data source in Terraform will zip your `.py` files automatically.

---

## Clean Up

To remove all resources created by this project:
```
terraform destroy
```

---

## Contact

For questions or issues, please contact the project
