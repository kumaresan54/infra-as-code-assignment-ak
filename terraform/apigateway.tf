# API Gateway HTTP API
resource "aws_apigatewayv2_api" "api" {
  name          = "UserAPI-${var.prefix}"
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