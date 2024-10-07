variable "prefix" {
  description = "An identifier for the apigateway deployment"
  type        = string
}

variable "identifier" {
  description = "The identifier for the deployment"
  type        = string
}

variable "environment" {
  description = "The environment where the module will be deployed"
  type        = string
}

variable "root_domain" {
  description = "The root domain which will be the base of the api gateway domain name"
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

variable "private_subnets" {
  description = "The subnets where the lambdas in vpc will be placed"
  type        = list(string)
  default     = []
}

variable "security_group_id" {
  description = "The security group id that will be associated with the lambdas in vpc"
  type        = string
  default     = ""
}

#====================================================================================
# Rest Api Gateway
#====================================================================================
variable "create_apigateway_account" {
  description = "Whether or not create the apigateway account resource to set the IAM role to allow logging"
  type        = bool
  default     = true
}

#====================================================================================
# Lambda Authorizer
#====================================================================================
variable "authorizer_result_ttl" {
  description = "The ttl in seconds of the authorizer validation"
  type        = number
}

variable "authorizer_lambda_path" {
  description = "The path where the authorizer lambda function is implemented"
  type        = string
}

variable "authorizer_permission_matrix_path" {
  description = "The path where the permission matrix resides for the authorizer. This file will be bundled together with the python code in the authorizer lambda"
  type        = string
}

variable "authorizer_lambda_timeout" {
  description = "Timeout of the api gateway lambda authoizer"
  type        = number
}

variable "authorizer_lambda_architectures" {
  description = "Architectures of the authorizer"
  type        = list(string)
}

variable "authorizer_lambda_runtime" {
  description = "Runtime of the authorizer"
  type        = string
}

variable "authorizer_lambda_handler" {
  description = "Handler of the authorizer"
  type        = string
}

variable "authorizer_lambda_cloudwatch_logs_retention_in_days" {
  description = "The retention in days of the cloudwatch logs of the authorizer"
  type        = number
}

variable "authorizer_lambda_layers" {
  description = "Layers to be associated with the authorizer"
  type        = list(string)
}

#====================================================================================
# Cors
#====================================================================================
variable "rest_api_cors_definition_path" {
  description = "Path where the rest api cors definitions are stored"
  type        = string
}

#====================================================================================
# Api gateway Integrations
#====================================================================================
variable "rest_api_integration_lambdas_config_path" {
  description = "Path where the rest api integration lambdas are defined"
  type        = string
}

variable "integration_lambda_code_base_path" {
  description = "The base path where the code for the lambda is defined, the actual folder where terraform will look into to find the code of the lambda will be {integration_lambda_code_base_path}/{lambda_function_name}"
  type        = string
}

variable "integration_lambda_default_runtime" {
  description = "Runtime of the lambda"
  type        = string
  default     = "python3.12"
}

variable "integration_lambda_default_timeout" {
  description = "Timeout of the lambda"
  type        = number
  default     = 3
}

variable "integration_lambda_default_handler" {
  description = "Handler of the lambda"
  type        = string
  default     = "main.lambda_handler"
}

variable "integration_lambda_default_architectures" {
  description = "Architectures of the lambda"
  type        = list(string)
  default     = ["arm64"]
}

variable "integration_lambda_default_memory_size" {
  description = "Memory of the lambda"
  type        = number
  default     = 128
}

variable "integration_lambda_default_ephemeral_storage_size" {
  description = "The ephemeral storage size of the lambda"
  type        = number
  default     = 512
}

variable "integration_lambda_default_layers" {
  description = "Layers to attach to the lambda"
  type        = list(string)
  default     = []
}

variable "integration_lambda_default_cloudwatch_logs_retention_in_days" {
  description = "Log retentention in days for the lambda"
  type        = number
  default     = 30
}

variable "integration_lambda_default_environment_variables" {
  description = "The environment variables that will associated with the lambda"
  type        = map(string)
  default     = {}
}

variable "integration_lambda_default_in_vpc" {
  description = "Whether the lambda needs to be placed behind the vpc"
  type        = string
}

variable "integration_lambda_custom" {
  description = "Custom properties to associate to the lambda"
  type = object({
    environment_variables = optional(map(string), {})
    policies = optional(object({
      attach  = optional(bool, false)
      inline  = optional(string, "")
      managed = optional(list(string), [])
      }), {
      attach  = false
      inline  = ""
      managed = []
    })
  })
}

#====================================================================================
# Api gateway Stages
#====================================================================================
variable "rest_api_stages_path" {
  description = "Path of the file containing the definitions of the stages/deployments in the api gateway"
  type        = string
}
