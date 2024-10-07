output "lambda_function_name" {
  description = "A map associating the version of each lambda with their name"
  value       = { for version, config in module.lambda_integration : version => config.lambda_function_name }
}

output "lambda_function_role_name" {
  description = "A map associating the version of each lambda with their iam role name"
  value       = { for version, config in module.lambda_integration : version => config.lambda_role_name }
}

output "apigateway_method" {
  description = "The API method of the current integration"
  value       = aws_api_gateway_method.this
}

output "apigateway_integration" {
  description = "The outputs of the integration resource"
  value       = aws_api_gateway_integration.this
}
