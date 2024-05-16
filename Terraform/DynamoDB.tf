resource "aws_dynamodb_table" "webapp" {
  name           = "webapp"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "firstName"
  attribute {
    name = "firstName"
    type = "S"
  }
  tags = {
    Name        = "webapp"
  }

}