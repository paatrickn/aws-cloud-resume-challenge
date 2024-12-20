#API Gateway CloudWatch Permission

resource "aws_iam_role" "apigateway_cloudwatch_role" {
  name = "APIGatewayCloudWatchLogsRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apigateway_cloudwatch_policy" {
  role       = aws_iam_role.apigateway_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "account_settings" {
  cloudwatch_role_arn = aws_iam_role.apigateway_cloudwatch_role.arn
}




# API Gateway Section
# This line is the name of the terraform resource
resource "aws_api_gateway_rest_api" "incrementViewerTerraform-API" {
  # This name line is the name of the API inside of AWS
  name        = "incrementViewer-API-TEST"
  description = "API Gateway used to trigger lamda function to increment dynamodb table"
}

resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementViewerTerraform-API.id}"
  parent_id   = "${aws_api_gateway_rest_api.incrementViewerTerraform-API.root_resource_id}"
  path_part   = "incrementViewer-API"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.incrementViewerTerraform-API.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_resource.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_api_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementViewerTerraform-API.id}"
  resource_id = "${aws_api_gateway_resource.proxy_resource.id}"
  http_method = "${aws_api_gateway_method.proxy_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.test_lambda_function.invoke_arn}"
}
  resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.incrementViewerTerraform-API.id}"
  resource_id   = "${aws_api_gateway_rest_api.incrementViewerTerraform-API.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementViewerTerraform-API.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.test_lambda_function.invoke_arn}"
}


resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/api-gateway/incrementViewer-API-TEST"
  retention_in_days = 7 
}


resource "aws_api_gateway_deployment" "API_Increment_Viewer_Deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_api_integration,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = "${aws_api_gateway_rest_api.incrementViewerTerraform-API.id}"
}

resource "aws_api_gateway_stage" "testing_stage" {
  deployment_id = aws_api_gateway_deployment.API_Increment_Viewer_Deployment.id
  rest_api_id   = aws_api_gateway_rest_api.incrementViewerTerraform-API.id
  stage_name    = "testing_stage"
}


# This specifies the type of response to give back to the client. 
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.incrementViewerTerraform-API.id
  resource_id = aws_api_gateway_resource.proxy_resource.id
  http_method = aws_api_gateway_method.proxy_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "IntegrationResponse" {
  depends_on = [aws_api_gateway_integration.lambda_api_integration]
  rest_api_id = aws_api_gateway_rest_api.incrementViewerTerraform-API.id
  resource_id = aws_api_gateway_resource.proxy_resource.id
  http_method = aws_api_gateway_method.proxy_method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/xml" = <<EOF
#set($inputRoot = $input.path('$'))
<?xml version="1.0" encoding="UTF-8"?>
<message>
    $inputRoot.body
</message>
EOF
  }
}

# This sets up logging. 
resource "aws_api_gateway_method_settings" "API_Gateway_Settings" {
  rest_api_id = "${aws_api_gateway_rest_api.incrementViewerTerraform-API.id}"
  stage_name  = "${aws_api_gateway_stage.testing_stage.stage_name}"
  method_path = "*/*"
  settings {
    logging_level = "INFO"
    data_trace_enabled = true
    metrics_enabled = true
  }
}











