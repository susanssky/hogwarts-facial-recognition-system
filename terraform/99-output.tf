
output "api-endpoint" {
  value      = aws_api_gateway_stage.api-gateway-stage.invoke_url
  depends_on = [aws_api_gateway_stage.api-gateway-stage]
}

output "visitor-bucket" {
  value = aws_s3_bucket.s3_hogwarts_visitor.bucket
}

