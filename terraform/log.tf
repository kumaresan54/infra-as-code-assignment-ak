resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = local.lambda_functions
  name     = "/aws/lambda/${each.key}-${var.prefix}"
}
