variable "rest_apigateway_id" {
  description = "The id of the REST apigateway"
  type        = string
}

variable "rest_apigateway_root_resource_id" {
  description = "The id of the root resource of the REST apigateway"
  type        = string
}

variable "rest_apigateway_lambdas" {
  description = "The map containing the definition of the REST apigateway lambda integrations"
  type        = any
}
