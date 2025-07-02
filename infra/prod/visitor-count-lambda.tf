data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Package the Lambda function code
data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "${path.module}/lambda/increment-count.py"
  output_path = "${path.module}/lambda/function.zip"
}

# Lambda function
resource "aws_lambda_function" "visitor-counter-function" {
  filename         = data.archive_file.lambda_archive.output_path
  function_name    = "increment-visitor-count"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "increment-count.increment"
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  runtime = "python3.13"

  environment {
    variables = {
      ENVIRONMENT = "production"
      LOG_LEVEL   = "info"
      TABLE_NAME  = aws_dynamodb_table.dynodb-visitor-count.name
    }
  }

  tags = {
    Environment = "production"
    Application = "visitor-counter"
  }
}

resource "aws_lambda_function" "visitor-counter-get-count" {
  filename         = data.archive_file.lambda_archive.output_path
  function_name    = "get-visitor-count"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "increment-count.get_count"
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  runtime = "python3.13"

  environment {
    variables = {
      ENVIRONMENT = "production"
      LOG_LEVEL   = "info"
      TABLE_NAME  = aws_dynamodb_table.dynodb-visitor-count.name
    }
  }

  tags = {
    Environment = "production"
    Application = "visitor-counter"
  }
}

resource "aws_iam_policy" "dynamodb_access" {
  name        = "lambda-dynamodb-access"
  description = "Allow Lambda to access DynamoDB visitor count table"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.dynodb-visitor-count.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}