#====================================================================================
# Rest API Gateway core
#====================================================================================
module "rest_apigateway" {
  source = "./modules/rest-apigateway"

  prefix     = var.prefix
  identifier = local.identifier

  create_apigateway_account = var.create_apigateway_account
  hosted_zone_id            = var.hosted_zone_id

  cognito_user_pool_client_id = var.cognito_user_pool_client_id
  cognito_user_pool_id        = var.cognito_user_pool_id

  apigateway_domain_name                                         = local.apigateway_domain
  apigateway_authorizer_result_ttl                               = var.authorizer_result_ttl
  apigateway_authorizer_lambda_path                              = var.authorizer_lambda_path
  apigateway_authorizer_permission_matrix_path                   = var.authorizer_permission_matrix_path
  apigateway_authorizer_lambda_layers                            = var.authorizer_lambda_layers
  apigateway_authorizer_lambda_architectures                     = var.authorizer_lambda_architectures
  apigateway_authorizer_lambda_timeout                           = var.authorizer_lambda_timeout
  apigateway_authorizer_lambda_handler                           = var.authorizer_lambda_handler
  apigateway_authorizer_lambda_runtime                           = var.authorizer_lambda_runtime
  apigateway_authorizer_lambda_cloudwatch_logs_retention_in_days = var.authorizer_lambda_cloudwatch_logs_retention_in_days
}

#====================================================================================
# Resources that will be created for the integrations
#====================================================================================
module "rest_apigateway_resources" {
  source = "./modules/rest-apigateway-resources"

  rest_apigateway_id               = module.rest_apigateway.apigateway_api_id
  rest_apigateway_root_resource_id = module.rest_apigateway.apigateway_root_resource_id
  rest_apigateway_lambdas          = local.rest_apigateway_lambdas
}

module "rest_apigateway_integrations" {
  for_each = local.rest_apigateway_lambdas

  source = "./modules/rest-apigateway-integration"

  identifier = local.identifier

  request_validator_map = module.rest_apigateway.apigateway_request_validators_map
  apigateway_id         = module.rest_apigateway.apigateway_api_id


  lambda_name                              = "${var.prefix}-${each.key}"
  lambda_description                       = each.value.lambda_description
  lambda_path                              = lookup(each.value, "lambda_folder_path", "${var.integration_lambda_code_base_path}/${each.key}")
  lambda_timeout                           = lookup(each.value, "lambda_timeout", var.integration_lambda_default_timeout)
  lambda_layers                            = lookup(each.value, "lambda_layers", var.integration_lambda_default_layers)
  lambda_in_vpc                            = lookup(each.value, "lambda_in_vpc", var.integration_lambda_default_in_vpc)
  lambda_architectures                     = lookup(each.value, "lambda_architecture", var.integration_lambda_default_architectures)
  lambda_ephemeral_storage_size            = lookup(each.value, "lambda_ephemeral_storage_size", var.integration_lambda_default_ephemeral_storage_size)
  lambda_handler                           = lookup(each.value, "lambda_handler", var.integration_lambda_default_handler)
  lambda_memory_size                       = lookup(each.value, "lambda_memory_size", var.integration_lambda_default_memory_size)
  lambda_runtime                           = lookup(each.value, "lambda_runtime", var.integration_lambda_default_runtime)
  lambda_cloudwatch_logs_retention_in_days = lookup(each.value, "lambda_cloudwatch_logs_retention_in_days", var.integration_lambda_default_cloudwatch_logs_retention_in_days)
  lambda_custom                            = lookup(var.integration_lambda_custom, each.key, {})
  lambda_versions                          = each.value.lambda_versions
  lambda_environment_variables             = lookup(each.value, "lambda_environment_variables", var.integration_lambda_default_environment_variables)

  private_subnets   = var.private_subnets
  security_group_id = var.security_group_id

  integration_http_method        = each.value.integration_http_method
  integration_full_path          = each.value.integration_full_path
  integration_resource_id        = module.rest_apigateway_resources.rest_apigateway_resources_map[each.value.integration_full_path == "/" ? each.value.integration_full_path : trimprefix(each.value.integration_full_path, "/")]
  integration_request_validator  = each.value.integration_request_validator
  integration_request_parameters = lookup(each.value, "integration_request_parameters", {})
  integration_request_model      = lookup(each.value, "integration_request_model", null)
  integration_authorizer_id      = module.rest_apigateway.apigateway_authorizer_id
}

module "rest_apigateway_cors" {
  for_each = local.rest_apigateway_cors

  source = "./modules/rest-apigateway-cors"

  apigateway_id           = module.rest_apigateway.apigateway_api_id
  integration_resource_id = module.rest_apigateway_resources.rest_apigateway_resources_map[each.value.integration_full_path]
  cors_definition         = each.value.cors_definition

  depends_on = [module.rest_apigateway_integrations]
}

module "rest_apigateway_deployments" {
  for_each = local.rest_apigateway_stages

  source = "./modules/rest-apigateway-deployment"

  prefix     = var.prefix
  identifier = local.identifier

  stage_name                 = each.value.stage_name
  apigateway_id              = module.rest_apigateway.apigateway_api_id
  apigateway_domain_name     = module.rest_apigateway.apigateway_domain_name
  apigateway_usage_plan_info = each.value.usage_plans

  redeployment_trigger = timestamp()

  depends_on = [
    module.rest_apigateway_integrations,
    module.rest_apigateway_cors,
    module.rest_apigateway_resources
  ]
}
