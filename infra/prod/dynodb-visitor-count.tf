resource "aws_dynamodb_table" "dynodb-visitor-count" {
  name         = "dynodb-visitor-count"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "visitor_count_init" {
  table_name = aws_dynamodb_table.dynodb-visitor-count.name
  hash_key   = "id"

  item = jsonencode({
    id            = { "S": "main" }
    visitor_count = { "N": "0" }
  })
}
