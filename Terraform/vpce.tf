resource "aws_vpc_endpoint" "lambda-vpce" {
  vpc_id            = aws_vpc.webapp_VPC.id
  service_name      = "com.amazonaws.ap-south-1.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.webapp_route_table.id]
  private_dns_enabled = false
}