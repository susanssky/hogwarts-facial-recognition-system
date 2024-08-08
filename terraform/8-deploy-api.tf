
resource "aws_api_gateway_deployment" "api-gateway-deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(join("", [file("7-api-gateway.tf"), file("./modules/enabled-cors/main.tf")]))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_lambda_permission.visitor, aws_lambda_permission.allow_s3]
}
resource "aws_api_gateway_stage" "api-gateway-stage" {
  deployment_id = aws_api_gateway_deployment.api-gateway-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
}
