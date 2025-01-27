resource "aws_iam_openid_connect_provider" "github_oidc" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "9e99a48a96e95d3e5ae7a86a5b3f5f7ff5ff5b7a" # Update with the thumbprint for GitHub's OIDC provider
  ]
}
