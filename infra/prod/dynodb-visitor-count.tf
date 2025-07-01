resource "aws_dynamodb_table" "dynodb-visitor-count" {
  name         = "dynodb-visitor-count"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "visitor_count"

  attribute {
    name = "visitor_count"
    type = "N"
  }
}
