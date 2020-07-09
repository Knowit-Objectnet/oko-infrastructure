resource "aws_api_gateway_resource" "weight_reporting" {
  rest_api_id = data.aws_api_gateway_rest_api.ombruk_api.id
  parent_id   = data.aws_api_gateway_rest_api.ombruk_api.root_resource_id
  path_part   = "weight-reporting"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = data.aws_api_gateway_rest_api.ombruk_api.id
  parent_id   = aws_api_gateway_resource.weight_reporting.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = data.aws_api_gateway_rest_api.ombruk_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
  
  request_parameters = {
    "method.request.path.proxy" = true
  }  
}

resource "aws_api_gateway_integration" "weight_reporting" {
  rest_api_id = data.aws_api_gateway_rest_api.ombruk_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy_any.http_method

  type                    = "HTTP_PROXY"
  uri                     = "http://${data.aws_lb.ecs_lb.dns_name}:${var.lb_port}"
  integration_http_method = "ANY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  connection_type = "VPC_LINK"
  connection_id   = data.aws_api_gateway_vpc_link.ombruk_api.id
}