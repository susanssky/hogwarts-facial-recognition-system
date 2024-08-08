########## first role
resource "aws_iam_role" "registered" {
  name = "${local.project_name}-registered-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

}
resource "aws_iam_role_policy_attachment" "registered-attach" {
  count      = length(local.policy_arns)
  role       = aws_iam_role.registered.name
  policy_arn = local.policy_arns[count.index]
}



########## second role
resource "aws_iam_role" "visitor" {
  name = "${local.project_name}-visitor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

}
resource "aws_iam_role_policy_attachment" "visitor-attach" {
  role       = aws_iam_role.visitor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_role_policy" "test_policy" {
  depends_on = [aws_s3_bucket.s3_hogwarts_visitor]
  name       = "${local.project_name}-s3Put-policy"
  role       = aws_iam_role.visitor.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${aws_s3_bucket.s3_hogwarts_visitor.bucket}/*"
      },
    ]
  })
}


