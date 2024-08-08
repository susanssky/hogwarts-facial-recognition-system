########## first lambda
data "archive_file" "registered" {
  type        = "zip"
  source_dir  = "./lambda/registered"
  output_path = "./registered.zip"
}

resource "aws_lambda_function" "registered" {
  depends_on    = [aws_s3_bucket.s3_hogwarts_registerd, aws_dynamodb_table.dynamodb_table, aws_rekognition_collection.rekognition_collection]
  function_name = "${local.project_name}-registered-lambda"

  filename         = data.archive_file.registered.output_path
  source_code_hash = data.archive_file.registered.output_base64sha256
  handler          = "index.handler"
  role             = aws_iam_role.registered.arn
  runtime          = "nodejs20.x"
  timeout          = 60
  environment {
    variables = {
      TABLE      = aws_dynamodb_table.dynamodb_table.name
      COLLECTION = aws_rekognition_collection.rekognition_collection.collection_id
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_cloudwatch" {
  name              = "/aws/lambda/${aws_lambda_function.registered.function_name}"
  retention_in_days = 1
}


resource "aws_lambda_permission" "allow_s3" {
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.registered.function_name
  principal      = "s3.amazonaws.com"
  source_arn     = aws_s3_bucket.s3_hogwarts_registerd.arn
  source_account = local.source_account
}
########## second lambda
data "archive_file" "visitor" {
  type        = "zip"
  source_dir  = "./lambda/visitor"
  output_path = "./visitor.zip"
}


resource "aws_lambda_function" "visitor" {
  depends_on       = [aws_s3_bucket.s3_hogwarts_visitor, aws_dynamodb_table.dynamodb_table, aws_rekognition_collection.rekognition_collection]
  function_name    = "${local.project_name}-visitor-lambda"
  filename         = data.archive_file.visitor.output_path
  source_code_hash = data.archive_file.visitor.output_base64sha256
  handler          = "index.handler"
  role             = aws_iam_role.registered.arn
  runtime          = "nodejs20.x"
  timeout          = 60
  environment {
    variables = {
      BUCKET     = aws_s3_bucket.s3_hogwarts_visitor.bucket
      TABLE      = aws_dynamodb_table.dynamodb_table.name
      COLLECTION = aws_rekognition_collection.rekognition_collection.collection_id
    }
  }
}

# (add trigger) in lambda
resource "aws_lambda_permission" "visitor" {
  depends_on    = [aws_api_gateway_resource.hogwarts]
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor.function_name
  principal     = "apigateway.amazonaws.com"
  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/GET${aws_api_gateway_resource.hogwarts.path}"

}
