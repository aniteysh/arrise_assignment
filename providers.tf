provider "aws" {
  alias  = "account_a"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::000000000000:role/TerraformAdminRole"
  }
}

provider "aws" {
  alias  = "account_b"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::111111111111:role/TerraformAdminRole"
  }
}