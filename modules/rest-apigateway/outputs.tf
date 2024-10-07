output "apigateway_domain_name" {
  description = "The domain name of the api gateaway"
  value       = aws_api_gateway_domain_name.this.domain_name
}

output "apigateway_api_id" {
  description = "The id of the api gateway"
  value       = aws_api_gateway_rest_api.this.id
}

output "apigateway_domain_certificate_arn" {
  description = "The arn of the certificate which is associated with the api gateway domain"
  value       = aws_acm_certificate.this.arn
}

output "apigateway_root_resource_id" {
  description = "The id of the root resource of the api gateway"
  value       = aws_api_gateway_rest_api.this.root_resource_id
}

output "apigateway_authorizer_id" {
  description = "The id of the authorizer that is created"
  value       = aws_api_gateway_authorizer.this.id
}

output "apigateway_response_bad_request_body_400" {
  description = "The outputs of the api gateway response for the bad request body 400"
  value       = aws_api_gateway_gateway_response.bad_request_body_400
}
output "apigateway_response_route_not_found_404" {
  description = "The outputsof the api gateway response for the 404 not found"
  value       = aws_api_gateway_gateway_response.route_not_found_404
}

output "apigateway_request_validators_map" {
  description = "The map containing the request validators names with their id"
  value = {
    "body-only"   = aws_api_gateway_request_validator.body_only.id
    "params-only" = aws_api_gateway_request_validator.params_only.id
    "all"         = aws_api_gateway_request_validator.all.id
    "none"        = aws_api_gateway_request_validator.none.id
  }
}
