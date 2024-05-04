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
}