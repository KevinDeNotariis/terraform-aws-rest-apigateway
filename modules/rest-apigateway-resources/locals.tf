locals {
  integration_resources_map = merge({
    layer_1 = toset([
      for key, config in var.rest_apigateway_lambdas : split("/", config.integration_full_path)[0] if config.integration_full_path != "/"
    ])
    }, {
    for num in [2, 3, 4, 5, 6, 7, 8, 9, 10] : "layer_${num}" => toset([
      for key, config in var.rest_apigateway_lambdas : {
        previous = join("/", slice(split("/", config.integration_full_path), 0, num - 1))
        current  = split("/", config.integration_full_path)[num - 1]
      } if can(split("/", config.integration_full_path)[num - 1])
    ])
  })
}
