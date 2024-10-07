variable "prefix" {
  description = "An identifier for the apigateway deployment"
  type        = string
}

variable "identifier" {
  description = "The identifier for the deployment"
  type        = string
}

variable "hosted_zone_id" {
  description = "The id of the public hosted zone where the api gateway alias will be created"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Id of the cognito user pool that will be associated with the authorizer lambda"
  type        = string
}

variable "cognito_user_pool_client_id" {
  description = "The client id of the associated user pool"
  type        = string
}

#====================================================================================
# Rest Api Gateway
#====================================================================================
variable "create_apigateway_account" {
  description = "Whether or not create the apigateway account resource to set the IAM role to allow logging"
  type        = bool
  default     = true
}

variable "apigateway_domain_name" {
  description = "Custom domain name to assign to the Rest Api Gateway"
  type        = string
}

#====================================================================================
# Lambda Authorizer variables
#====================================================================================
variable "apigateway_authorizer_result_ttl" {
  description = "The ttl in seconds of the authorizer validation"
  type        = number
}

variable "apigateway_authorizer_lambda_path" {
  description = "The path where the authorizer lambda function is implemented"
  type        = string
}

variable "apigateway_authorizer_permission_matrix_path" {
  description = "The path where the permission matrix resides for the authorizer. This file will be bundled together with the python code in the authorizer lambda"
  type        = string
}

variable "apigateway_authorizer_lambda_timeout" {
  description = "Timeout of the api gateway lambda authoizer"
  type        = number
}

variable "apigateway_authorizer_lambda_architectures" {
  description = "Architectures of the authorizer"
  type        = list(string)
}

variable "apigateway_authorizer_lambda_runtime" {
  description = "Runtime of the authorizer"
  type        = string
}

variable "apigateway_authorizer_lambda_handler" {
  description = "Handler of the authorizer"
  type        = string
}

variable "apigateway_authorizer_lambda_cloudwatch_logs_retention_in_days" {
  description = "The retention in days of the cloudwatch logs of the authorizer"
  type        = number
}

variable "apigateway_authorizer_lambda_layers" {
  description = "Layers to be associated with the authorizer"
  type        = list(string)
}
