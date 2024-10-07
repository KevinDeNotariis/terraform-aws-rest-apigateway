output "rest_api_keys_ssm_parameter_name" {
  description = "A map associating to each usage plan the parameter store containing the api keys"
  value       = { for key, value in aws_ssm_parameter.rest_apigateway_api_keys : key => value.name }
}
