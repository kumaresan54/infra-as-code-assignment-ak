resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/register_user"
}

resource "aws_cloudwatch_log_group" "verify_user_logs" {
  name = "/aws/lambda/verify_user"
}