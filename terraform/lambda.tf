# Create zip archives for each Lambda function
resource "archive_file" "lambda_zip" {
  for_each = local.lambda_functions

  type        = "zip"
  source_file = each.value.filename
  output_path = "../lambda/${each.key}.zip"
}

# Create Lambda functions from zip archives
resource "aws_lambda_function" "lambda" {
  for_each = local.lambda_functions

  function_name = "${each.key}-${var.prefix}"
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