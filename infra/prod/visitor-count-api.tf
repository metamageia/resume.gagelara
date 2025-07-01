resource "aws_apigatewayv2_api" "vistor-count-api" {
  name          = "visitor-count-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]        
    allow_methods = ["GET"]      
    allow_headers = ["*"]        
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.vistor-count-api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.visitor-counter-function.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_count" {
  api_id    = aws_apigatewayv2_api.vistor-count-api.id
  route_key = "GET /count"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.vistor-count-api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor-counter-function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.vistor-count-api.execution_arn}/*/*"
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.vistor-count-api.api_endpoint
  description = "The invoke URL of the API Gateway"
}