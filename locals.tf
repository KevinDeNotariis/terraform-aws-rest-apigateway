locals {
  identifier = "${var.environment}-${var.identifier}"

  apigateway_domain = "${var.prefix}.${var.environment}.${var.root_domain}"

  rest_apigateway_lambdas = yamldecode(file(var.rest_api_integration_lambdas_config_path))
  rest_apigateway_stages  = yamldecode(file(var.rest_api_stages_path))
  rest_apigateway_cors    = yamldecode(file(var.rest_api_cors_definition_path))
}
