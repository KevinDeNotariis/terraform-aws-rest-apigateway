locals {
  prefix      = "complete"
  identifier  = random_id.this.hex
  environment = "test"

  lambda_layer_powertools = "arn:aws:lambda:${data.aws_region.current.name}:017000801446:layer:AWSLambdaPowertoolsPythonV2-Arm64:51"
}

data "aws_route53_zone" "current" {
  name = var.hosted_zone_name
}

resource "random_id" "this" {
  byte_length = 4
}

module "cognito" {
  source  = "KevinDeNotariis/cognito/aws"
  version = "2.0.1"

  prefix      = local.prefix
  identifier  = local.identifier
  environment = local.environment

  root_domain    = var.hosted_zone_name
  hosted_zone_id = data.aws_route53_zone.current.zone_id

  users_config_file_path         = "${path.module}/cognito_config/users.yaml"
  groups_config_file_path        = "${path.module}/cognito_config/groups.yaml"
  user_pool_client_callback_urls = ["http://localhost:3000/"]
  user_pool_client_logout_urls   = ["http://localhost:3000/"]

  verification_email_subject_by_link      = "Jungle - Email Confirmation"
  verification_email_message_by_link_path = "${path.module}/cognito_config/verification_email_message.txt"

  invite_email_subject      = "Welcome to the Jungle"
  invite_email_message_path = "${path.module}/cognito_config/invite_email_message.txt"
  invite_sms_message        = "Hello {username}, please sign up at: {####}"

  create_dummy_record = true

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}

module "rest_apigateway" {
  source = "../.."

  prefix      = local.prefix
  environment = local.environment
  identifier  = local.identifier

  root_domain    = var.hosted_zone_name
  hosted_zone_id = data.aws_route53_zone.current.id

  cognito_user_pool_client_id = module.cognito.cognito_user_pool_client_id
  cognito_user_pool_id        = module.cognito.cognito_user_pool_id

  rest_api_integration_lambdas_config_path = "${path.module}/api_config/rest_apigateway_integrations.yaml"
  rest_api_stages_path                     = "${path.module}/api_config/rest_apigateway_stages.yaml"
  rest_api_cors_definition_path            = "${path.module}/api_config/rest_apigateway_cors.yaml"
  authorizer_permission_matrix_path        = "${path.module}/api_config/rest_apigateway_permissions.yaml"

  authorizer_lambda_architectures                     = ["arm64"]
  authorizer_lambda_runtime                           = "python3.12"
  authorizer_lambda_handler                           = "main.lambda_handler"
  authorizer_lambda_layers                            = [local.lambda_layer_powertools]
  authorizer_lambda_path                              = "${path.module}/lambdas/authorizer"
  authorizer_lambda_timeout                           = 5
  authorizer_result_ttl                               = 0
  authorizer_lambda_cloudwatch_logs_retention_in_days = 30

  integration_lambda_code_base_path                            = "${path.module}/lambdas/rest"
  integration_lambda_default_architectures                     = ["arm64"]
  integration_lambda_default_runtime                           = "python3.12"
  integration_lambda_default_cloudwatch_logs_retention_in_days = 30
  integration_lambda_default_handler                           = "main.lambda_handler"
  integration_lambda_custom                                    = {}
  integration_lambda_default_ephemeral_storage_size            = 512
  integration_lambda_default_in_vpc                            = false
  integration_lambda_default_memory_size                       = 128
  integration_lambda_default_timeout                           = 3
  integration_lambda_default_layers                            = [local.lambda_layer_powertools]
  integration_lambda_default_environment_variables = {
    POWERTOOLS_LOG_LEVEL = "DEBUG"
  }
}
