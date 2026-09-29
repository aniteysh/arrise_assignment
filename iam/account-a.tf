resource "aws_iam_group" "group1" {
  provider = aws.account_a
  name     = "group1"
}

resource "aws_iam_group" "group2" {
  provider = aws.account_a
  name     = "group2"
}

resource "aws_iam_user" "engine" {
  provider = aws.account_a
  name     = "engine"
}

resource "aws_iam_user" "ci" {
  provider = aws.account_a
  name     = "ci"
}

resource "aws_iam_user" "opsadmin" {
  provider = aws.account_a
  name     = "opsadmin"
}

resource "aws_iam_user" "developer" {
  provider = aws.account_a
  name     = "developer"
}

resource "aws_iam_user_group_membership" "group1_members" {
  provider = aws.account_a

  user = [
    aws_iam_user.engine.name,
    aws_iam_user.ci.name
  ]

  groups = [
    aws_iam_group.group1.name
  ]
}

resource "aws_iam_user_group_membership" "group2_members" {
  provider = aws.account_a

  user = [
    aws_iam_user.opsadmin.name,
    aws_iam_user.developer.name
  ]

  groups = [
    aws_iam_group.group2.name
  ]
}

resource "aws_iam_access_key" "engine" {
  provider = aws.account_a
  user     = aws_iam_user.engine.name
}

resource "aws_iam_access_key" "ci" {
  provider = aws.account_a
  user     = aws_iam_user.ci.name
}

resource "aws_iam_group_policy_attachment" "group2_admin" {
  provider   = aws.account_a
  group      = aws_iam_group.group2.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "roleA" {
  provider = aws.account_a
  name     = "roleA"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          AWS = [
            aws_iam_user.opsadmin.arn,
            aws_iam_user.developer.arn
          ]
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "roleA_policy" {
  provider = aws.account_a
  role     = aws_iam_role.roleA.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
      {
        Effect   = "Deny"
        Action   = "iam:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "roleB" {
  provider = aws.account_a
  name     = "roleB"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          AWS = [
            aws_iam_user.engine.arn,
            aws_iam_user.ci.arn
          ]
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "roleB_policy" {
  provider = aws.account_a
  role     = aws_iam_role.roleB.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = "sts:AssumeRole"

        Resource = "arn:aws:iam::111111111111:role/roleC"
      }
    ]
  })
}