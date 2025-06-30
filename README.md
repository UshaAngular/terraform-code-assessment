# AWS Lambda S3 Access CloudFormation Templates

This repository contains CloudFormation templates to provision:
- IAM policy for Lambda S3 access
- S3 buckets for inbound and outbound data
- Lambda functions to write to/read from S3

---

## File Structure

```
.
├── create-iam-policy.yaml         # Defines IAM policy for Lambda S3 access
├── create-s3-bucket.yaml         # Provisions inbound and outbound S3 buckets
├── lambda-s3-access.yaml         # (Optional)  Lambda for both operations read and write
└── README.md                     # This documentation
```

---

## Assumptions

- AWS CLI configured with sufficient permissions to create IAM roles, policies, Lambda functions, and S3 buckets.
- S3 bucket names provided are globally unique and conform to AWS naming rules.
- The IAM role used by Lambda has the necessary permissions to access the specified S3 buckets.
- Python 3.12 runtime is available for Lambda functions.
- the required parameter values (bucket names, IAM role ARN) are provided during stack creation.


## Further enhancements in future
later this code can be further enhanced to process the file in outbound and write to inbound bucket after any fie processing logic is performed.
Trigger the Lambda only when a new file is uploaded to the outbound bucket, ensuring each file is processed once.
To persist state, we can use DynamoDB, S3 object metadata, or S3 event-driven design. Lambda itself cannot remember state between runs.

## Template Descriptions

### 1. `create-iam-policy.yaml`
Creates an IAM policy granting Lambda functions permission to read from and write to the specified S3 buckets.  
**Parameters:**  
- `InboundBucketName`
- `OutboundBucketName`

### 2. `create-s3-bucket.yaml`
Creates two S3 buckets: one for inbound data and one for outbound data.  
**Parameters:**  
- `inboundbucketname`
- `outboundbucketname`

### 3. `lambda-s3-access.yaml`
Deploys  Lambda function to:
-  write to the inbound bucket file named from-lambda.txt.
-  reads from the outbound bucket sample.txt which is uploaded already

**Parameters:**  
- `InboundBucketName`
- `OutboundBucketName`
- `LambdaRoleArn` (IAM role ARN for Lambda execution)

---

## Deployment Steps

1. **Create S3 Buckets**
   ```sh
   aws cloudformation create-stack \
     --stack-name s3-buckets \
     --template-body file://create-s3-bucket.yaml \
     --parameters ParameterKey=inboundbucketname,ParameterValue=<your-inbound-bucket> \
                  ParameterKey=outboundbucketname,ParameterValue=<your-outbound-bucket>
   ```

2. **Create IAM Policy**
   ```sh
   aws cloudformation create-stack \
     --stack-name lambda-s3-policy \
     --template-body file://create-iam-policy.yaml \
     --parameters ParameterKey=InboundBucketName,ParameterValue=<your-inbound-bucket> \
                  ParameterKey=OutboundBucketName,ParameterValue=<your-outbound-bucket>
   ```
   Attach the created policy to your Lambda execution role.

3. **Deploy Lambda Functions**
   ```sh
   aws cloudformation create-stack \
     --stack-name lambda-s3-access \
     --template-body file://lambda-s3-access.yaml \
     --parameters ParameterKey=InboundBucketName,ParameterValue=<your-inbound-bucket> \
                  ParameterKey=OutboundBucketName,ParameterValue=<your-outbound-bucket> \
                  ParameterKey=LambdaRoleArn,ParameterValue=<your-lambda-role-arn>
   ```

---

## Notes

- Replace parameter values with your actual bucket names and IAM role ARN.
- Ensure the IAM role used by Lambda has the policy created in step 2 attached.
- The Lambda functions use environment variables to reference bucket names.

---"# terraform-code-assessment" 
