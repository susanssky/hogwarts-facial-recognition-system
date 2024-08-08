resource "aws_api_gateway_rest_api" "api" {
  name               = "${local.project_name}-api"
  binary_media_types = ["image/jpeg", "image/png"]
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "bucket" {
  path_part   = "{bucket}"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_resource" "filename" {
  path_part   = "{filename}"
  parent_id   = aws_api_gateway_resource.bucket.id
  rest_api_id = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_resource" "hogwarts" {
  path_part   = "hogwarts"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}


module "ebabled_cors" {
  source      = "./modules/enabled-cors"
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_ids = {
    filename = aws_api_gateway_resource.filename.id
    hogwarts = aws_api_gateway_resource.hogwarts.id
  }
  depends_on = [aws_api_gateway_resource.bucket, aws_api_gateway_resource.filename, aws_api_gateway_resource.hogwarts]
}

variable "region" {
  default = "eu-west-2"
}

resource "aws_api_gateway_method" "filename" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.filename.id
  http_method   = "PUT"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.bucket"   = true
    "method.request.path.filename" = true
  }
}
resource "aws_api_gateway_method_response" "put_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.filename.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

# # Every method request must add an integration request. It must be added.
resource "aws_api_gateway_integration" "filename_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.filename.id
  http_method             = aws_api_gateway_method.filename.http_method
  integration_http_method = "PUT"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.region}:s3:path/{bucket}/{filename}"
  credentials             = aws_iam_role.visitor.arn
  request_parameters = {
    "integration.request.path.bucket"   = "method.request.path.bucket"
    "integration.request.path.filename" = "method.request.path.filename"
  }
}

resource "aws_api_gateway_integration_response" "put_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.filename.http_method
  status_code = aws_api_gateway_method_response.put_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

resource "aws_api_gateway_method" "hogwarts" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.hogwarts.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "get_200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.hogwarts.id
  http_method = aws_api_gateway_method.hogwarts.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}
resource "aws_api_gateway_integration" "hogwarts_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.hogwarts.id
  http_method             = aws_api_gateway_method.hogwarts.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.visitor.invoke_arn
}

