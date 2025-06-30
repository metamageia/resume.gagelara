resource "aws_dynamodb_table" "resume_gagelara_dynodb" {
  name         = "resume_gagelara_dynodb"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
