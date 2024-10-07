output "rest_apigateway_domain" {
  description = "Domain name of the api gateway"
  value       = module.rest_apigateway.apigateway_domain_name
}

output "rest_apigateway_api_keys_ssm_parameter_name" {
  description = "The ssm parameter names for the api keys of the different deployments"
  value       = { for version, config in module.rest_apigateway_deployments : version => config.rest_api_keys_ssm_parameter_name }
}
