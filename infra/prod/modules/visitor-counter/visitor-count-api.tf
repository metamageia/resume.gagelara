resource "aws_apigatewayv2_api" "visitor-count-api" {
  name          = "visitor-count-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET"]
    allow_headers = ["*"]
  }
}

output "api_url" {
  value       = aws_apigatewayv2_api.visitor-count-api.api_endpoint
  description = "The invoke URL of the API Gateway"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.visitor-count-api.id
  name        = "$default"
  auto_deploy = true
}


### Increment Count API

resource "aws_apigatewayv2_integration" "lambda_increment_visitors" {
  api_id                 = aws_apigatewayv2_api.visitor-count-api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.visitor-counter-increment.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "increment" {
  api_id    = aws_apigatewayv2_api.visitor-count-api.id
  route_key = "GET /increment"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_increment_visitors.id}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor-counter-increment.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor-count-api.execution_arn}/*/*"
}


### Get Count API

resource "aws_apigatewayv2_integration" "lambda_get_visitors" {
  api_id                 = aws_apigatewayv2_api.visitor-count-api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.visitor-counter-get-count.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_count" {
  api_id    = aws_apigatewayv2_api.visitor-count-api.id
  route_key = "GET /count"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_get_visitors.id}"
}

resource "aws_lambda_permission" "apigw_get_count" {
  statement_id  = "AllowAPIGatewayInvokeGetCount"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor-counter-get-count.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.visitor-count-api.execution_arn}/*/*"
}










