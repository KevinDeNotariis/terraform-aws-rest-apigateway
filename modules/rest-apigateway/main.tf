#====================================================================================
# Api Gateway
#====================================================================================
resource "aws_api_gateway_rest_api" "this" {
  name = "${var.prefix}-${var.identifier}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  put_rest_api_mode = "merge"
}

#====================================================================================
# IAM for API gateway to push cloudwatch logs
#====================================================================================
data "aws_iam_policy_document" "api_gateway_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api_gateway" {
  count = var.create_apigateway_account ? 1 : 0

  name                = "${var.prefix}-${var.identifier}"
  assume_role_policy  = data.aws_iam_policy_document.api_gateway_assume.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"]
}

resource "aws_api_gateway_account" "this" {
  count = var.create_apigateway_account ? 1 : 0

  cloudwatch_role_arn = aws_iam_role.api_gateway[0].arn
}

#====================================================================================
# Api gateway Custom Responses
#====================================================================================
resource "aws_api_gateway_gateway_response" "bad_request_body_400" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  status_code   = "400"
  response_type = "BAD_REQUEST_BODY"

  response_templates = {
    "application/json" = "{\"message\": \"Invalid request body\", \"cause\": \"$context.error.validationErrorString\"}"
  }
}

resource "aws_api_gateway_gateway_response" "route_not_found_404" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  status_code   = "404"
  response_type = "MISSING_AUTHENTICATION_TOKEN"

  response_templates = {
    "application/json" = "{\"message\": \"Not Found\"}"
  }
}

#====================================================================================
# Api gateway Custom Domain Name
#====================================================================================
resource "aws_acm_certificate" "this" {
  domain_name       = var.apigateway_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_type
  zone_id         = var.hosted_zone_id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

resource "aws_api_gateway_domain_name" "this" {
  regional_certificate_arn = aws_acm_certificate_validation.this.certificate_arn
  domain_name              = var.apigateway_domain_name
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "this" {
  zone_id = var.hosted_zone_id
  name    = var.apigateway_domain_name
  type    = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.this.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.this.regional_zone_id
  }
}

#====================================================================================
# Authorizer
#====================================================================================
module "lambda_cognito_authorizer" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7"

  function_name = "${var.prefix}-authorizer-${var.identifier}"
  description   = "Authorizer a request to an API gateway from a Cognito Bearer authorization"
  architectures = var.apigateway_authorizer_lambda_architectures
  timeout       = var.apigateway_authorizer_lambda_timeout
  handler       = var.apigateway_authorizer_lambda_handler
  runtime       = var.apigateway_authorizer_lambda_runtime
  source_path = [
    {
      path             = var.apigateway_authorizer_lambda_path,
      pip_requirements = true

    },
    {
      path = var.apigateway_authorizer_permission_matrix_path
    }
  ]
  layers = var.apigateway_authorizer_lambda_layers

  cloudwatch_logs_retention_in_days = var.apigateway_authorizer_lambda_cloudwatch_logs_retention_in_days

  attach_policy_json    = false
  attach_tracing_policy = true

  tracing_mode = "Active"

  environment_variables = {
    POWERTOOLS_LOG_LEVEL        = "DEBUG"
    USER_POOL_ID                = var.cognito_user_pool_id
    APP_CLIENT_ID               = var.cognito_user_pool_client_id
    PERMISSIONS_MATRIX_FILENAME = basename(var.apigateway_authorizer_permission_matrix_path)
  }
}

resource "aws_api_gateway_authorizer" "this" {
  name                             = "${var.prefix}-cognito-${var.identifier}"
  rest_api_id                      = aws_api_gateway_rest_api.this.id
  type                             = "REQUEST"
  identity_source                  = "method.request.header.Authorization"
  authorizer_result_ttl_in_seconds = var.apigateway_authorizer_result_ttl
  authorizer_uri                   = module.lambda_cognito_authorizer.lambda_function_invoke_arn
  authorizer_credentials           = aws_iam_role.authorizer.arn
}

data "aws_iam_policy_document" "authorizer" {
  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = [module.lambda_cognito_authorizer.lambda_function_arn]
  }
}

resource "aws_iam_role" "authorizer" {
  name               = "${var.prefix}-cognito-${var.identifier}"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume.json

  inline_policy {
    name   = "permissions"
    policy = data.aws_iam_policy_document.authorizer.json
  }
}

resource "aws_lambda_permission" "authorizer" {
  statement_id_prefix = "ApiGatewayAuth"
  action              = "lambda:InvokeFunction"
  function_name       = module.lambda_cognito_authorizer.lambda_function_name
  principal           = "apigateway.amazonaws.com"

  source_arn = format("arn:aws:execute-api:%s:%s:%s/authorizers/%s",
    data.aws_region.current.name,
    data.aws_caller_identity.current.account_id,
    aws_api_gateway_rest_api.this.id,
    aws_api_gateway_authorizer.this.id,
  )
}
