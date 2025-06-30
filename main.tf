provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_s3_bucket" "inbound" {
  bucket = var.inbound_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "outbound" {
  bucket = var.outbound_bucket_name
  force_destroy = true
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-s3-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-s3-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:CreateBucket",
          "s3:DeleteBucket"
        ]
        Resource = [
          "${aws_s3_bucket.inbound.arn}/*",
          "${aws_s3_bucket.outbound.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket"
        ]
        Resource = [
          "${aws_s3_bucket.inbound.arn}",
          "${aws_s3_bucket.outbound.arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "lambda_write_inbound" {
  type        = "zip"
  source_file = "${path.module}/lambda_write_inbound.py"
  output_path = "${path.module}/lambda_write_inbound.zip"
}

data "archive_file" "lambda_read_outbound" {
  type        = "zip"
  source_file = "${path.module}/lambda_read_outbound.py"
  output_path = "${path.module}/lambda_read_outbound.zip"
}

resource "aws_lambda_function" "write_inbound" {
  function_name = "WriteToInboundbucketFunction"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_write_inbound.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.lambda_write_inbound.output_path

  environment {
    variables = {
      INBOUND_BUCKET  = aws_s3_bucket.inbound.bucket
      OUTBOUND_BUCKET = aws_s3_bucket.outbound.bucket
    }
  }
}

resource "aws_lambda_function" "read_outbound" {
  function_name = "ReadFromOutboundbucketFunction"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_read_outbound.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.lambda_read_outbound.output_path

  environment {
    variables = {
      INBOUND_BUCKET  = aws_s3_bucket.inbound.bucket
      OUTBOUND_BUCKET = aws_s3_bucket.outbound.bucket
    }
  }
}