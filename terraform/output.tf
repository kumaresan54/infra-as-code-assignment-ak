output "api_gateway_url" {

  value = aws_apigatewayv2_api.api.api_endpoint
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.users.arn
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.my_bucket.arn
}