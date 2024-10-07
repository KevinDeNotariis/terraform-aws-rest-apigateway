resource "aws_api_gateway_method" "this" {
  rest_api_id   = var.apigateway_id
  resource_id   = var.integration_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "this" {
  for_each = var.cors_definition.method_response

  rest_api_id = var.apigateway_id
  resource_id = var.integration_resource_id
  http_method = aws_api_gateway_method.this.http_method
  status_code = lookup(each.value, "status_code", 200)

  response_models     = each.value.response_models
  response_parameters = each.value.response_parameters
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id = var.apigateway_id
  resource_id = var.integration_resource_id
  http_method = aws_api_gateway_method.this.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }
}

resource "aws_api_gateway_integration_response" "this" {
  for_each = var.cors_definition.integration_response

  rest_api_id = var.apigateway_id
  resource_id = aws_api_gateway_integration.this.resource_id
  http_method = aws_api_gateway_method.this.http_method
  status_code = lookup(each.value, "status_code", 200)

  response_parameters = each.value.response_parameters
}
