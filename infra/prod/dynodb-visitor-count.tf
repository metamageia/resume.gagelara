resource "aws_dynamodb_table" "dynodb-visitor-count" {
  name         = "dynodb-visitor-count"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

