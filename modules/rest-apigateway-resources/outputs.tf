output "rest_apigateway_resources_map" {
  description = "A map associating each api path to its resource id"
  value = merge(
    { "/" = var.rest_apigateway_root_resource_id },
    { for resource in aws_api_gateway_resource.layer_1 : trimprefix(resource.path, "/") => resource.id },
    { for resource in aws_api_gateway_resource.layer_2 : trimprefix(resource.path, "/") => resource.id },
    { for resource in aws_api_gateway_resource.layer_3 : trimprefix(resource.path, "/") => resource.id },
    { for resource in aws_api_gateway_resource.layer_4 : trimprefix(resource.path, "/") => resource.id },
    { for resource in aws_api_gateway_resource.layer_5 : trimprefix(resource.path, "/") => resource.id },
    { for resource in aws_api_gateway_resource.layer_6 : trimprefix(resource.path, "/") => resource.id },
    { for resource in aws_api_gateway_resource.layer_7 : trimprefix(resource.path, "/") => resource.id },
    { for resource in aws_api_gateway_resource.layer_8 : trimprefix(resource.path, "/") => resource.id },
    { for resource in aws_api_gateway_resource.layer_9 : trimprefix(resource.path, "/") => resource.id },
    { for resource in aws_api_gateway_resource.layer_10 : trimprefix(resource.path, "/") => resource.id },
  )
}
