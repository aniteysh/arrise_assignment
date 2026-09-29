resource "aws_iam_role" "roleC" {
  provider = aws.account_b
  name     = "roleC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::000000000000:role/roleB"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "roleC_policy" {
  provider = aws.account_b
  role     = aws_iam_role.roleC.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = "s3:*"

        Resource = [
          "arn:aws:s3:::my-build-artifacts-bucket",
          "arn:aws:s3:::my-build-artifacts-bucket/*"
        ]
      }
    ]
  })
}