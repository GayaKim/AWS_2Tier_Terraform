resource "aws_key_pair" "gayakey" {
  key_name   = "gayakey"
  public_key = file("gayakey.pub")
}

data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "^amzn2-"

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-gp2"] // Kernel 5.10, SSD Volume Type
    #values = ["amzn2-ami-hvm-*-gp2"] // Kernel 4.14, SSD Volume Type
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] #values = ["arm64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "web" {
  description = "Allow HTTP, SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from VPC"
    from_port   = var.server_port # 80
    to_port     = var.server_port # 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_http_ssh_intance"
  }
}

resource "aws_instance" "web_pub" {
  ami                         = coalesce(var.image_id, data.aws_ami.amzlinux2.id) # image_id = var.image_id == "" ? data.aws_ami.amzlinux2.id : var.image_id
  instance_type               = var.instance_type                                 # "t2.micro"
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = aws_key_pair.gayakey.id
  subnet_id                   = aws_subnet.pub_a.id
  user_data                   = file("userdata.tftpl")
  depends_on                  = [aws_db_instance.tf-db]
  user_data_replace_on_change = true
  tags = {
    Name = "tf-web-pub"
  }
}

#create own AMI
resource "aws_ami_from_instance" "web-img" {
  name               = "tf-web-3-22.10.25"
  source_instance_id = aws_instance.web_pub.id
  # snapshot_without_reboot = true
  tags = {
    Name = "web-"
  }
}

resource "aws_launch_configuration" "web" {
  name_prefix     = "lc-web-"
  image_id        = aws_ami_from_instance.web-img.id
  instance_type   = var.instance_type # "t2.micro"
  security_groups = [aws_security_group.web.id]
  key_name        = aws_key_pair.gayakey.id
  depends_on      = [aws_ami_from_instance.web-img]

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name_prefix          = "asg-web-"
  launch_configuration = aws_launch_configuration.web.name
  vpc_zone_identifier  = [aws_subnet.pri_a.id, aws_subnet.pri_c.id]

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "tf-asg-web"
    propagate_at_launch = true
  }
}

