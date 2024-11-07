#====================================================================================
# Api Gateway Model
#====================================================================================
resource "aws_api_gateway_model" "this" {
  count = var.integration_request_model == null ? 0 : 1

  rest_api_id  = var.apigateway_id
  name         = lookup(var.integration_request_model, "name", "")
  description  = lookup(var.integration_request_model, "description", "")
  content_type = lookup(var.integration_request_model, "content_type", "")
  schema       = lookup(var.integration_request_model, "schema", "") == "" ? "" : jsonencode(var.integration_request_model["schema"])
}

#====================================================================================
# Api Gateway Method and integration
#====================================================================================
resource "aws_api_gateway_method" "this" {
  rest_api_id          = var.apigateway_id
  resource_id          = var.integration_resource_id
  http_method          = var.integration_http_method
  api_key_required     = true
  authorization        = "CUSTOM"
  authorizer_id        = var.integration_authorizer_id
  request_models       = var.integration_request_model == null ? {} : { (var.integration_request_model.content_type) = aws_api_gateway_model.this[0].name }
  request_validator_id = var.request_validator_map[var.integration_request_validator]
  request_parameters = merge(
    var.integration_request_parameters,
    {
      "method.request.header.Content-Type" = true
    }
  )

  depends_on = [
    aws_api_gateway_model.this
  ]
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = var.apigateway_id
  resource_id             = aws_api_gateway_method.this.resource_id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = format(
    "arn:aws:apigateway:%s:lambda:path/2015-03-31/functions/%s/invocations",
    data.aws_region.current.name,
    "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.lambda_name}-$${stageVariables.environment}-${var.identifier}"
  )
}

#====================================================================================
# Lambda function
#====================================================================================
module "lambda_integration" {
  for_each = toset(var.lambda_versions)

  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7"

  function_name          = "${var.lambda_name}-${each.key}-${var.identifier}"
  hash_extra             = "${var.lambda_name}-${each.key}-${var.identifier}"
  description            = var.lambda_description
  handler                = var.lambda_handler
  runtime                = var.lambda_runtime
  architectures          = var.lambda_architectures
  memory_size            = var.lambda_memory_size
  ephemeral_storage_size = var.lambda_ephemeral_storage_size
  timeout                = var.lambda_timeout
  publish                = true
  source_path            = "${var.lambda_path}/${each.key}"
  layers                 = var.lambda_layers

  cloudwatch_logs_retention_in_days = var.lambda_cloudwatch_logs_retention_in_days
  environment_variables = merge(
    var.lambda_environment_variables,
    var.lambda_custom.environment_variables
  )

  attach_policy_json    = lookup(var.lambda_custom["policies"], "attach", false)
  policy_json           = var.lambda_custom["policies"]["inline"]
  attach_tracing_policy = true

  attach_network_policy  = var.lambda_in_vpc
  vpc_subnet_ids         = var.lambda_in_vpc ? var.private_subnets : null
  vpc_security_group_ids = var.lambda_in_vpc ? [var.security_group_id] : null
}

resource "aws_iam_role_policy_attachment" "lambda" {
  for_each = {
    for elem in setproduct(
      var.lambda_versions,
      toset(var.lambda_custom["policies"]["managed"])
      ) : "${elem[0]}_${elem[1]}" => {
      version = elem[0]
      policy  = elem[1]
    }
  }

  role       = module.lambda_integration[each.value.version].lambda_role_name
  policy_arn = each.value.policy
}

#====================================================================================
# Lambda permissions
#====================================================================================
resource "aws_lambda_permission" "lambda_integration" {
  for_each = toset(var.lambda_versions)

  statement_id_prefix = "ApiGateway${title(each.key)}"
  action              = "lambda:InvokeFunction"
  function_name       = module.lambda_integration[each.key].lambda_function_name
  principal           = "apigateway.amazonaws.com"

  source_arn = format("arn:aws:execute-api:%s:%s:%s/%s/%s/%s",
    data.aws_region.current.name,
    data.aws_caller_identity.current.account_id,
    var.apigateway_id,
    each.key,
    upper(var.integration_http_method),
    var.integration_full_path,
  )
}

#====================================================================================
# Api Gateway Documentation
#====================================================================================
resource "aws_api_gateway_documentation_part" "this" {
  location {
    type   = "METHOD"
    method = var.integration_http_method == "ANY" ? "*" : var.integration_http_method
    path   = "${var.integration_full_path == "/" ? "" : "/"}${var.integration_full_path}"
  }

  properties = jsonencode({
    description = var.lambda_description
  })
  rest_api_id = var.apigateway_id
}
