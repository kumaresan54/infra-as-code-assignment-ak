resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsRole-${var.prefix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_oidc.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:sub" = "repo:kumaresan54/infra-as-code-assignment-ak:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}


resource "aws_iam_policy" "github_actions_policy" {
  name        = "GitHubActionsPolicy-${var.prefix}"
  description = "Policy for GitHub Actions to deploy infrastructure"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
          # "s3:GetObject",
          # "s3:ListBucket",
          # "s3:PutObject",
          # "s3:GetBucketPolicy",
          # "s3:GetBucketAcl",
          # "s3:GetBucketCORS",
          # "s3:GetBucketWebsite",
          # "s3:GetBucketVersioning",
          # "s3:GetAccelerateConfiguration",
          "ec2:Describe*",
          "ec2:TerminateInstances",
          "apigateway:POST",
          "apigateway:GET",
          "dynamodb:CreateTable",
          "dynamodb:DescribeTable",
          "dynamodb:ListTables",
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateTable",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTagsOfResource",
          "dynamodb:DeleteTable",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:CreatePolicy",
          "iam:AttachRolePolicy",
          "iam:GetPolicy",
          "iam:GetRole",
          "iam:ListRolePolicies",
          "iam:GetPolicyVersion",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:DeletePolicy",
          "iam:DeleteRole",
          "iam:PutRolePolicy",
          "iam:ListPolicyVersions",
          "iam:PassRole",
          "iam:GetRolePolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource",
          "logs:DeleteLogGroup",
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:ListFunctions",
          "lambda:ListVersionsByFunction",
          "lambda:GetFunctionCodeSigningConfig",
          "lambda:AddPermission",
          "lambda:GetPolicy",
          "lambda:RemovePermission",
          "apigateway:DELETE"


        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
  policy_arn = aws_iam_policy.github_actions_policy.arn
  role       = aws_iam_role.github_actions_role.name
}