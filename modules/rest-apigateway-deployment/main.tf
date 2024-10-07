#====================================================================================
# Log Group
#====================================================================================
resource "aws_cloudwatch_log_group" "this" {
  name              = "API-Gateway-Execution-Logs_${var.apigateway_id}/${var.stage_name}"
  retention_in_days = var.apigateway_stage_logs_retention_in_days
}

#====================================================================================
# Deployment
#====================================================================================
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = var.apigateway_id
  description = "Deployment of API"

  triggers = {
    redeployment = var.redeployment_trigger
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id          = var.apigateway_id
  deployment_id        = aws_api_gateway_deployment.this.id
  stage_name           = var.stage_name
  description          = "${title(var.stage_name)} stage"
  xray_tracing_enabled = true

  variables = {
    environment = var.stage_name
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.this.arn
    format = jsonencode({
      authorizeError               = "$context.authorize.error"
      authorizeLatency             = "$context.authorize.latency"
      authorizerStatus             = "$context.authorize.status"
      authorizerIntegrationLatency = "$context.authorizer.integrationLatency"
      authorizerIntegrationStatus  = "$context.authorizer.integrationStatus"
      authorizerLatency            = "$context.authorizer.latency"
      authorizerRequestId          = "$context.authorizer.requestId"
      authorizerStatus             = "$context.authorizer.status"
      authenticateError            = "$context.authenticate.error"
      authenticateLatency          = "$context.authenticate.latency"
      authenticateStatus           = "$context.authenticate.status"
      customDomainBasePathMatched  = "$context.customDomain.basePathMatched"
      integrationError             = "$context.integration.error"
      integrationLatency           = "$context.integration.latency"
      integrationRequestId         = "$context.integration.requestId"
      integrationStatus            = "$context.integration.status"
      lambdaIntegrationLatency     = "$context.integrationLatency"
      lambdaIntegrationStatus      = "$context.integrationStatus"
      responseLatency              = "$context.responseLatency"
      wafError                     = "$context.waf.error"
      wafLatency                   = "$context.waf.latency"
      wafStatus                    = "$context.waf.status"
      xRayTraceId                  = "$context.xrayTraceId"
      errorMessage                 = "$context.error.message"

      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      authorizer              = "$context.authorizer.error"
    })
  }
}

#====================================================================================
# WAF
#====================================================================================
resource "aws_wafv2_web_acl_association" "this" {
  count = var.waf_arn == null ? 0 : 1

  resource_arn = aws_api_gateway_stage.this.arn
  web_acl_arn  = var.waf_arn
}

#====================================================================================
# Base Path Mapping
#====================================================================================
resource "aws_api_gateway_base_path_mapping" "example" {
  api_id      = var.apigateway_id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = var.apigateway_domain_name
  base_path   = aws_api_gateway_stage.this.stage_name
}

#====================================================================================
# Api gateway Usage Plan and API Key
#====================================================================================
resource "aws_api_gateway_usage_plan" "this" {
  for_each = var.apigateway_usage_plan_info

  name        = "${var.prefix}-${var.stage_name}-${each.key}-${var.identifier}"
  description = "Usage plan for ${each.key} and stage: ${var.stage_name} of api gateway: ${var.prefix}-${var.identifier}"

  api_stages {
    api_id = var.apigateway_id
    stage  = aws_api_gateway_stage.this.stage_name
  }

  quota_settings {
    limit  = each.value.quota_limit
    offset = each.value.quota_offset
    period = each.value.quota_period
  }

  throttle_settings {
    burst_limit = each.value.throttle_burst
    rate_limit  = each.value.throttle_rate
  }
}

resource "aws_api_gateway_api_key" "this" {
  for_each = local.entity_api_keys_map

  name = "${var.prefix}-${var.stage_name}-${each.key}-${var.identifier}"
}

resource "aws_api_gateway_usage_plan_key" "this" {
  for_each = local.entity_api_keys_map

  key_id        = aws_api_gateway_api_key.this[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this[each.value.entity].id
}

#====================================================================================
# Store useful parameter in parameter store
#====================================================================================
resource "aws_ssm_parameter" "rest_apigateway_api_keys" {
  for_each = { for key, elem in aws_api_gateway_api_key.this : key => elem.value }

  name  = "/${var.prefix}-${var.identifier}/rest-apigateway/${var.stage_name}/api-key/${each.key}"
  type  = "SecureString"
  value = each.value
}
