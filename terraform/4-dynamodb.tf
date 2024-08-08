resource "aws_dynamodb_table" "dynamodb_table" {
  name                        = "${local.project_name}-table"
  billing_mode                = "PROVISIONED"
  read_capacity               = 5
  write_capacity              = 5
  hash_key                    = "rekognitionId"
  deletion_protection_enabled = false

  attribute {
    name = "rekognitionId"
    type = "S"
  }

  tags = {
    tag = "build-${local.project_name}"
  }
}
