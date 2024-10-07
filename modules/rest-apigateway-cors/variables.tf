variable "apigateway_id" {
  description = "Id of the api gateway"
  type        = string
}
variable "integration_resource_id" {
  description = "The id of the resource to which the cors will be associated with"
  type        = string
}
variable "cors_definition" {
  description = "The definition of the cors"
  type        = any
}
