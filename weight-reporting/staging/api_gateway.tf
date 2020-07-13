

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

resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = data.aws_api_gateway_rest_api.ombruk_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id   = data.aws_api_gateway_rest_api.ombruk_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = aws_api_gateway_method.options_method.http_method
  response_models = {
        "application/json" = "Empty"
    }
  status_code = "200"
  response_parameters = {
        "method.response.header.Access-Control-Allow-Credentials" = true
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
  depends_on = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration" "options_integration" {
    rest_api_id   = data.aws_api_gateway_rest_api.ombruk_api.id
    resource_id   = aws_api_gateway_resource.proxy.id
    http_method   = aws_api_gateway_method.options_method.http_method
    type          = "MOCK"
    passthrough_behavior = "WHEN_NO_TEMPLATES"
    request_templates = {
      "application/json" = "{'statusCode': 200}"
    }
    depends_on    = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
    rest_api_id   = data.aws_api_gateway_rest_api.ombruk_api.id
    resource_id   = aws_api_gateway_resource.proxy.id
    http_method   = aws_api_gateway_method.options_method.http_method
    status_code   = aws_api_gateway_method_response.options_200.status_code
    response_parameters = {
        "method.response.header.Access-Control-Allow-Credentials" = "'true'"
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = var.cors_origin
    }
    depends_on = [aws_api_gateway_method_response.options_200, aws_api_gateway_integration.options_integration]
}


resource "aws_api_gateway_integration" "weight_reporting" {
  rest_api_id = data.aws_api_gateway_rest_api.ombruk_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy_any.http_method

  type                    = "HTTP_PROXY"
  uri                     = "http://${data.aws_lb.ecs_lb.dns_name}:${var.lb_port}/{proxy}"
  integration_http_method = "ANY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  connection_type = "VPC_LINK"
  connection_id   = data.aws_api_gateway_vpc_link.ombruk_api.id
}