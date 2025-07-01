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
  handler          = "increment-count.handler"
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256

  runtime = "python3.13"

  environment {
    variables = {
      ENVIRONMENT = "production"
      LOG_LEVEL   = "info"
    }
  }

  tags = {
    Environment = "production"
    Application = "visitor-counter"
  }
}