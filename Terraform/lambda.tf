data "archive_file" "python_zip_code" {
  type        = "zip"
  source_file = "${var.python_code_location}/lambda-function.py"
  output_path = "${path.module}lambda-function.zip"
}

resource "aws_lambda_function" "form" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.python_zip_code.output_path
  function_name = "form"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda-function.lambda_handler"
  runtime = "python3.12"
    vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = [aws_subnet.subnet-private-1.id, aws_subnet.subnet-private-2.id]
    security_group_ids = [aws_security_group.lambda-SG.id]
  }
}