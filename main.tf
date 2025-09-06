provider "aws" {
  region = "eu-north-1"
}

# DynamoDb
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Carrots"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "CarrotId"
  range_key      = "EatTimestamp"

  attribute {
    name = "CarrotId"
    type = "S"
  }

  attribute {
    name = "EatTimestamp"
    type = "S"
  }

  tags = {
    Name        = "carrot-table"
    Environment = var.environment
  }
}

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

resource "aws_iam_role" "carrot-lambda" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach basic Lambda execution policy for CloudWatch logs
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.carrot-lambda.name
}


# Create policy for DynamoDB access
data "aws_iam_policy_document" "lambda_dynamodb" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [
      aws_dynamodb_table.basic-dynamodb-table.arn,
      "${aws_dynamodb_table.basic-dynamodb-table.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_dynamodb" {
  name   = "lambda_dynamodb_policy"
  role   = aws_iam_role.carrot-lambda.id
  policy = data.aws_iam_policy_document.lambda_dynamodb.json
}

# Lambda
data "archive_file" "carrot-code" {
  type        = "zip"
  source_file = "${path.module}/lambda/index.js"
  output_path = "${path.module}/lambda/function.zip"
}

resource "aws_lambda_function" "carrot-lambda" {
  filename         = data.archive_file.carrot-code.output_path
  function_name    = "example_lambda_function"
  role             = aws_iam_role.carrot-lambda.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.carrot-code.output_base64sha256

  runtime = "nodejs20.x"

  environment {
    variables = {
      ENVIRONMENT = var.environment
      LOG_LEVEL   = "info"
    }
  }

  tags = {
    Environment = var.environment
    Application = "carrot-lambda"
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "carrot_api" {
  name        = "carrot-api"
  description = "API for Carrot CRUD operations"
  
  tags = {
    Environment = var.environment
    Application = "carrot-api"
  }
}

# API Gateway Resource
resource "aws_api_gateway_resource" "carrots" {
  rest_api_id = aws_api_gateway_rest_api.carrot_api.id
  parent_id   = aws_api_gateway_rest_api.carrot_api.root_resource_id
  path_part   = "carrots"
}

# POST Method
resource "aws_api_gateway_method" "carrots_post" {
  rest_api_id   = aws_api_gateway_rest_api.carrot_api.id
  resource_id   = aws_api_gateway_resource.carrots.id
  http_method   = "POST"
  authorization = "NONE"
}

# GET Method
resource "aws_api_gateway_method" "carrots_get" {
  rest_api_id   = aws_api_gateway_rest_api.carrot_api.id
  resource_id   = aws_api_gateway_resource.carrots.id
  http_method   = "GET"
  authorization = "NONE"
}

# POST Integration
resource "aws_api_gateway_integration" "lambda_integration_post" {
  rest_api_id = aws_api_gateway_rest_api.carrot_api.id
  resource_id = aws_api_gateway_resource.carrots.id
  http_method = aws_api_gateway_method.carrots_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.carrot-lambda.invoke_arn
}

# GET Integration
resource "aws_api_gateway_integration" "lambda_integration_get" {
  rest_api_id = aws_api_gateway_rest_api.carrot_api.id
  resource_id = aws_api_gateway_resource.carrots.id
  http_method = aws_api_gateway_method.carrots_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.carrot-lambda.invoke_arn
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.carrot-lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.carrot_api.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "carrot_deployment" {
  depends_on = [
    aws_api_gateway_method.carrots_post,
    aws_api_gateway_method.carrots_get,
    aws_api_gateway_integration.lambda_integration_post,
    aws_api_gateway_integration.lambda_integration_get,
  ]

  rest_api_id = aws_api_gateway_rest_api.carrot_api.id
  stage_name  = var.environment
}

