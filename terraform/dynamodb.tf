# DynamoDB table for user data
resource "aws_dynamodb_table" "users" {
  name           = "users-${var.prefix}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user"
  attribute {
    name = "user"
    type = "S"
  }
}