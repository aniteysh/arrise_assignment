resource "aws_iam_user_policy" "ci_pipeline" {
  provider = aws.account_a

  name = "ci-pipeline-least-privilege"
  user = aws_iam_user.ci.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      # ECR authentication
      {
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },

      # Push image to the specific repository
      {
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]

        Resource = "arn:aws:ecr:us-east-1:000000000000:repository/my-app"
      },

      # Register ECS task definition
      {
        Effect = "Allow"

        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition"
        ]

        Resource = "*"
      },

      # Deploy task definition to specific ECS service
      {
        Effect = "Allow"

        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]

        Resource = "arn:aws:ecs:us-east-1:000000000000:service/my-cluster/my-service"
      },

      # Pass only the ECS roles required by the task definition
      {
        Effect = "Allow"

        Action = [
          "iam:PassRole"
        ]

        Resource = [
          "arn:aws:iam::000000000000:role/ecsTaskExecutionRole",
          "arn:aws:iam::000000000000:role/ecsTaskRole"
        ]
      },

      # Read-only access to build artifacts
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]

        Resource = "arn:aws:s3:::my-build-artifacts-bucket/*"
      },

      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = "arn:aws:s3:::my-build-artifacts-bucket"
      }
    ]
  })
}