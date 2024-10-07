variable "prefix" {
  description = "An identifier for the apigateway deployment"
  type        = string
}

variable "identifier" {
  description = "An identifier which will be used to create the unique name of each resource"
  type        = string
}

variable "apigateway_id" {
  description = "The Id of the api gateway"
  type        = string
}

variable "apigateway_domain_name" {
  description = "Custom Domain name of the api gateway"
  type        = string
}

variable "stage_name" {
  description = "The name of the stage to create"
  type        = string
}

variable "redeployment_trigger" {
  description = "An hash telling when the api needs to be re-deployed"
  type        = string
}

variable "apigateway_stage_logs_retention_in_days" {
  description = "The log retention in days of the stages logs"
  type        = number
  default     = 30
}

variable "waf_arn" {
  description = "The arn of the WAF to associate to the API gateway"
  type        = string
  default     = null
}

variable "apigateway_usage_plan_info" {
  description = "The usage plan information of the api keys"
  type = map(object({
    quota_limit    = number
    quota_offset   = number
    quota_period   = string
    throttle_burst = number
    throttle_rate  = number
    api_keys       = list(string)
  }))
}
