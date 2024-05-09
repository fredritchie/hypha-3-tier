resource "aws_security_group" "ALB-SG" {
  name        = "ALB-SG"
  description = "Allow port 80 inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.webapp_VPC.id

  tags = {
    Name = "ALB-SG"
  }
}
resource "aws_security_group_rule" "allow_port_80_to_ALB" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ALB-SG.id
}
resource "aws_security_group_rule" "outbound_allow_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ALB-SG.id
  from_port         = 0
}
resource "aws_security_group" "Ec2-SG" {
  name        = "Ec2-SG"
  description = "Allow port 80 inbound from ALB and all outbound traffic"
  vpc_id      = aws_vpc.webapp_VPC.id

  tags = {
    Name = "Ec2-SG"
  }
}
resource "aws_security_group_rule" "allow_port_80_to_EC2" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ALB-SG.id
  security_group_id        = aws_security_group.Ec2-SG.id
}
resource "aws_security_group_rule" "outbound_allow_all_Ec2" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.Ec2-SG.id
  from_port         = 0
}
resource "aws_security_group" "lambda-SG" {
  name        = "lambda-SG"
  description = "Allow all inbound from EC2"
  vpc_id      = aws_vpc.webapp_VPC.id

  tags = {
    Name = "lambda-SG"
  }
}

resource "aws_security_group_rule" "allow_port_all_from_EC2" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.Ec2-SG.id
  security_group_id        = aws_security_group.lambda-SG.id
}
resource "aws_security_group_rule" "outbound_allow_all_from_lambda" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda-SG.id
  from_port         = 0
}


resource "aws_security_group" "vpce-SG" {
  name        = "vpce-SG"
  description = "Allow all inbound from lambda"
  vpc_id      = aws_vpc.webapp_VPC.id

  tags = {
    Name = "vpce-SG"
  }
}

resource "aws_security_group_rule" "allow_port_all_from_lambda" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.lambda-SG.id
  security_group_id        = aws_security_group.vpce-SG.id
}
resource "aws_security_group_rule" "outbound_allow_all_from_vpce" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpce-SG.id
  from_port         = 0
}