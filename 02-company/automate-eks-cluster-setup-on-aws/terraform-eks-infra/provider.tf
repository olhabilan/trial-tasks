provider "aws" {
  region = var.region
}

provider "aws" {
  region = var.region
  alias  = "eks"
  assume_role {
    role_arn = local.assume_role
  }
}