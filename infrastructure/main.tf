

# Declare the IAM role
# This just creates the role for the lambda function to assume which it does in the next section.
resource "aws_iam_role" "iam_for_lambda_increment_viewer" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode(
  {
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_dynamodb_access" {
  name        = "lambda_dynamodb_access"
  description = "Allow Lambda function to access DynamoDB"

  policy = jsonencode(
  {
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
        ],
        Resource = [
          "arn:aws:dynamodb:us-west-1:437441844878:table/cloud_resume_stats"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda_increment_viewer.name
  policy_arn = aws_iam_policy.lambda_dynamodb_access.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.iam_for_lambda_increment_viewer.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_function" "test_lambda_function" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "packedlambda.zip"
  function_name = "lambda_function"
  role          = aws_iam_role.iam_for_lambda_increment_viewer.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"

}

# Archive a single file.

data "archive_file" "init" {
  type        = "zip"
  source_dir = "${path.module}/lambda/"
  output_path = "${path.module}/packedlambda.zip"
}

resource "aws_lambda_function_url" "test_latest" {
  function_name      = aws_lambda_function.test_lambda_function.function_name
  authorization_type = "NONE"

  cors {
  allow_credentials = true
  allow_origins     = ["*"]
  allow_methods     = ["*"]
  allow_headers     = ["date", "keep-alive"]
  expose_headers    = ["keep-alive", "date"]
  max_age           = 86400
  }
}