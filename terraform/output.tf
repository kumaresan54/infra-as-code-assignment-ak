output "api_gateway_url" {

  value = aws_apigatewayv2_api.api.api_endpoint
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.users.arn
}

output "s3_bucket_arn" {
  value = module.s3_bucket.s3_bucket_arn
}