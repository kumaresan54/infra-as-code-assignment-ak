# DynamoDB table for user data
resource "aws_dynamodb_table" "users" {
  name           = "Users"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user"
  attribute {
    name = "user"
    type = "S"
  }
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_exec_role" {
  name = "LambdaExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

resource "aws_iam_policy" "function_logging_policy" {
  name   = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role = aws_iam_role.lambda_exec_role.id
  policy_arn = aws_iam_policy.function_logging_policy.arn
}


resource "aws_iam_policy" "lambda_s3_access_policy" {
  name        = "LambdaS3AccessPolicy"
  description = "Policy that allows Lambda function to get objects from S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::my-unique-bucket-name-ak/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_s3_access_policy.arn
  role       = aws_iam_role.lambda_exec_role.id
}


# IAM policy for Lambda functions to access DynamoDB
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "LambdaDynamoDBPolicy"
  role   = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem"]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.users.arn
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/register_user"
}

resource "aws_cloudwatch_log_group" "verify_user_logs" {
  name = "/aws/lambda/verify_user"
}


# Lambda functions and their corresponding routes
locals {
  lambda_functions = {
    "register_user" = {
      "handler"  = "register_user.handler",
      "filename" = "lambda/register_user.py",
      "route"    = "/register"
    },
    "verify_user" = {
      "handler"  = "verify_user.handler",
      "filename" = "lambda/verify_user.py",
      "route"    = "/"
    }
  }
}

# Create zip archives for each Lambda function
resource "archive_file" "lambda_zip" {
  for_each = local.lambda_functions

  type        = "zip"
  source_file = each.value.filename
  output_path = "${path.module}/lambda/${each.key}.zip"
}

# Create Lambda functions from zip archives
resource "aws_lambda_function" "lambda" {
  for_each = local.lambda_functions

  function_name = "${each.key}"
  runtime       = "python3.8"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = each.value.handler
  filename      = archive_file.lambda_zip[each.key].output_path
  timeout       = 10   

  environment {
    variables = {
      DB_TABLE_NAME = aws_dynamodb_table.users.name
      WEBSITE_S3 = aws_s3_bucket.my_bucket.bucket
    }
  }

  depends_on = [archive_file.lambda_zip]

  source_code_hash = archive_file.lambda_zip[each.key].output_base64sha256

}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "api" {
  name          = "UserAPI"
  protocol_type = "HTTP"
}

# API Gateway integrations for each Lambda function
resource "aws_apigatewayv2_integration" "integration" {
  for_each = aws_lambda_function.lambda

  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = each.value.arn
}

# API Gateway routes for each Lambda function
resource "aws_apigatewayv2_route" "route" {
  for_each = aws_apigatewayv2_integration.integration

  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET ${local.lambda_functions[each.key].route}"
  target    = "integrations/${each.value.id}"
}

# Explicitly create an API Gateway deployment
resource "aws_apigatewayv2_deployment" "deployment" {
  api_id = aws_apigatewayv2_api.api.id

  # Ensure this deployment happens after all routes and integrations are created
  depends_on = [
    aws_apigatewayv2_route.route
  ]
}

# API Gateway stage (deployment)
resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.api.id
  name   = "$default"
  # auto_deploy = true

  # Ensure the deployment is associated with the stage
  deployment_id = aws_apigatewayv2_deployment.deployment.id
}

# Lambda permissions to allow API Gateway to invoke the Lambda functions
resource "aws_lambda_permission" "lambda_permission" {
  for_each = aws_lambda_function.lambda

  statement_id  = "AllowAPIGatewayInvoke${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# Output the API Gateway URL
output "api_gateway_url" {
  description = "API Gateway URL"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

# Output the ARN for DynamoDB, S3, and API Gateway
output "dynamodb_table_arn" {
  value = aws_dynamodb_table.users.arn
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.my_bucket.arn
}

# Create an S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name-ak" 
}

# Define the files to be uploaded to the S3 bucket
locals {
  s3_files = {
    "index.html"  = "files/index.html"  
    "error.html"  = "files/error.html"  
  }
}

resource "aws_s3_object" "website_files" {
  for_each = local.s3_files

  bucket = aws_s3_bucket.my_bucket.bucket
  key    = each.key    
  source = each.value 
}