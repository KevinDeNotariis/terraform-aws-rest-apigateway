locals {
  entity_api_keys_map = {
    for elem in flatten([
      for entity, info in var.apigateway_usage_plan_info : [
        for api_key in info.api_keys : {
          entity  = entity
          api_key = api_key
        }
      ]
    ]) : "${elem.entity}-${elem.api_key}" => elem
  }
}
