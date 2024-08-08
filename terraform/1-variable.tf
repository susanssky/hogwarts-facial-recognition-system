
# s3
variable "s3_buckets" {
  default = [
    "registered",
    "vistor",
  ]
}

locals {
  project_name              = "facial-recognition"
  rekognition_collection_id = "Hogwarts"
  policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonRekognitionFullAccess",
  ]
  split_arn      = split(":", aws_iam_role.registered.arn)
  source_account = element([for item in local.split_arn : item if length(item) == 12], 0)
}


