resource "aws_api_gateway_resource" "layer_1" {
  for_each = local.integration_resources_map.layer_1

  rest_api_id = var.rest_apigateway_id
  parent_id   = var.rest_apigateway_root_resource_id
  path_part   = each.key
}

resource "aws_api_gateway_resource" "layer_2" {
  for_each = { for elem in try(local.integration_resources_map.layer_2, []) : "${elem.previous}/${elem.current}" => elem }

  rest_api_id = var.rest_apigateway_id
  parent_id   = aws_api_gateway_resource.layer_1[each.value.previous].id
  path_part   = each.value.current
}

resource "aws_api_gateway_resource" "layer_3" {
  for_each = { for elem in try(local.integration_resources_map.layer_3, []) : "${elem.previous}/${elem.current}" => elem }

  rest_api_id = var.rest_apigateway_id
  parent_id   = aws_api_gateway_resource.layer_2[each.value.previous].id
  path_part   = each.value.current
}

resource "aws_api_gateway_resource" "layer_4" {
  for_each = { for elem in try(local.integration_resources_map.layer_4, []) : "${elem.previous}/${elem.current}" => elem }

  rest_api_id = var.rest_apigateway_id
  parent_id   = aws_api_gateway_resource.layer_3[each.value.previous].id
  path_part   = each.value.current
}

resource "aws_api_gateway_resource" "layer_5" {
  for_each = { for elem in try(local.integration_resources_map.layer_5, []) : "${elem.previous}/${elem.current}" => elem }

  rest_api_id = var.rest_apigateway_id
  parent_id   = aws_api_gateway_resource.layer_4[each.value.previous].id
  path_part   = each.value.current
}

resource "aws_api_gateway_resource" "layer_6" {
  for_each = { for elem in try(local.integration_resources_map.layer_6, []) : "${elem.previous}/${elem.current}" => elem }

  rest_api_id = var.rest_apigateway_id
  parent_id   = aws_api_gateway_resource.layer_5[each.value.previous].id
  path_part   = each.value.current
}

resource "aws_api_gateway_resource" "layer_7" {
  for_each = { for elem in try(local.integration_resources_map.layer_7, []) : "${elem.previous}/${elem.current}" => elem }

  rest_api_id = var.rest_apigateway_id
  parent_id   = aws_api_gateway_resource.layer_6[each.value.previous].id
  path_part   = each.value.current
}

resource "aws_api_gateway_resource" "layer_8" {
  for_each = { for elem in try(local.integration_resources_map.layer_8, []) : "${elem.previous}/${elem.current}" => elem }

  rest_api_id = var.rest_apigateway_id
  parent_id   = aws_api_gateway_resource.layer_7[each.value.previous].id
  path_part   = each.value.current
}

resource "aws_api_gateway_resource" "layer_9" {
  for_each = { for elem in try(local.integration_resources_map.layer_9, []) : "${elem.previous}/${elem.current}" => elem }

  rest_api_id = var.rest_apigateway_id
  parent_id   = aws_api_gateway_resource.layer_8[each.value.previous].id
  path_part   = each.value.current
}

resource "aws_api_gateway_resource" "layer_10" {
  for_each = { for elem in try(local.integration_resources_map.layer_10, []) : "${elem.previous}/${elem.current}" => elem }

  rest_api_id = var.rest_apigateway_id
  parent_id   = aws_api_gateway_resource.layer_9[each.value.previous].id
  path_part   = each.value.current
}
