resource "aws_iam_policy" "policy_for_lambda" {
  name        = "write_DynamoDB_lambda"
  description = "Access to write to DynamoDB Table"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
       {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces"
      ],
      "Resource": "*"
    },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ],
        "Resource" : aws_dynamodb_table.webapp.arn
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
    }
  )
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-DynamoDB-write-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "DynamoDB lambda_policy_attachment"
  policy_arn = aws_iam_policy.policy_for_lambda.arn
  roles      = [aws_iam_role.lambda_role.name]
}



resource "aws_iam_policy" "policy_for_EC2" {
  name        = "invoke_lambda_function"
  description = "Access to invoke Lambda function"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "lambda:InvokeFunction",
        "Resource" : aws_lambda_function.form.arn
      }
    ]
    }
  )
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-lambda-invoke-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_policy_attachment" "ec2_policy_attachment" {
  name       = "ec2_lambda_policy_attachment"
  policy_arn = aws_iam_policy.policy_for_EC2.arn
  roles      = [aws_iam_role.ec2_role.name]
}

resource "aws_iam_instance_profile" "EC2_lambda_instance_profile" {
  name = "EC2_lambda_instance_profile"
  role = aws_iam_role.ec2_role.name
}