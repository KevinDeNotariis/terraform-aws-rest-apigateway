variable "identifier" {
  description = "An identifier which will be used to create the unique name of each resource"
  type        = string
}

variable "request_validator_map" {
  description = "A map with the request validators names and their ids"
  type        = map(string)
}

variable "apigateway_id" {
  description = "The Id of the api gateway"
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

variable "lambda_versions" {
  description = "The versions of the lambda to deploy"
  type        = list(string)
}

variable "lambda_name" {
  description = "Name of the lambda"
  type        = string
}

variable "lambda_description" {
  description = "Description of the lambda"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime of the lambda"
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Timeout of the lambda"
  type        = number
  default     = 3
}

variable "lambda_handler" {
  description = "Handler of the lambda"
  type        = string
  default     = "main.lambda_handler"
}

variable "lambda_architectures" {
  description = "Architectures of the lambda"
  type        = list(string)
  default     = ["arm64"]
}

variable "lambda_memory_size" {
  description = "Memory of the lambda"
  type        = number
  default     = 128
}

variable "lambda_ephemeral_storage_size" {
  description = "The ephemeral storage size of the lambda"
  type        = number
  default     = 512
}

variable "lambda_layers" {
  description = "Layers to attach to the lambda"
  type        = list(string)
  default     = []
}

variable "lambda_cloudwatch_logs_retention_in_days" {
  description = "Log retentention in days for the lambda"
  type        = number
  default     = 30
}

variable "lambda_environment_variables" {
  description = "The environment variables that will associated with the lambda"
  type        = map(string)
  default     = {}
}

variable "lambda_path" {
  description = "Where to find the lambda"
  type        = string
  default     = null
}

variable "lambda_in_vpc" {
  description = "Whether the lambda needs to be placed behind the vpc"
  type        = string
}

variable "lambda_custom" {
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

variable "integration_http_method" {
  description = "HTTP method of the integration for the lambda"
  type        = string
}

variable "integration_full_path" {
  description = "The path of the integration for the lambda"
  type        = string
}

variable "integration_resource_id" {
  description = "The Id of the api gateway resource where the lambda will be attached to"
  type        = string
}

variable "integration_request_validator" {
  description = "The request validator to associate to the integration"
  type        = string
}

variable "integration_request_model" {
  description = "The model to associate to the integration"
  type = object({
    name         = string
    description  = optional(string, "")
    content_type = optional(string)
    schema       = optional(any, null)
  })
  default = null
}

variable "integration_request_parameters" {
  description = "The parameters to validate in the request"
  type        = map(string)
  default     = {}
}

variable "integration_authorizer_id" {
  description = "The authorizer id"
  type        = string
}
