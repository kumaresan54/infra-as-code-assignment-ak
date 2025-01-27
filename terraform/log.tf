resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = local.lambda_functions
  name = "/aws/lambda/${each.key}-${var.prefix}"
}

# resource "aws_cloudwatch_log_group" "verify_user_logs" {
#   name = "/aws/lambda/verify_user"
# }