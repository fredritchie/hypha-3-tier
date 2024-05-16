data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical account ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
resource "tls_private_key" "key_for_webapp_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "webapp_keypair" {
  key_name   = "webapp_keypair"
  public_key = tls_private_key.key_for_webapp_keypair.public_key_openssh
}

resource "aws_launch_template" "webapp-template" {
  name            = "webapp-template"
  default_version = 1
  description     = "Launch template for webapp"

  disable_api_stop        = false
  disable_api_termination = false
  key_name                = "webapp_keypair"
  iam_instance_profile {
    name = aws_iam_instance_profile.EC2_lambda_instance_profile.name
  }
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t2.micro"
  image_id                             = data.aws_ami.ubuntu.id

  vpc_security_group_ids = [aws_security_group.Ec2-SG.id]
  tags = {
    Name = "webapp-template"
  }
  user_data = filebase64("user-data-script.sh")
}