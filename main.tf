resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.vpc_cidr
  availability_zone = var.availability_zone
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_route_table.public.id
}

resource "aws_instance" "app" {
  subnet_id     = aws_subnet.example.id
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = "${var.environment}-app-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-app01-bucket01"
  provisioner "local-exec" {
    command = "echo S3 bucket created successfully"
  }
}

resource "aws_iam_role" "app_role" {
  name = "test_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy" "app_policy" {
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:*"
      Resource = aws_s3_bucket.app_bucket.arn
    }]
  })

  depends_on = [
    aws_s3_bucket.app_bucket
  ]
}

resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.myvpc.id
  ingress {
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
}

resource "aws_instance" "app1" {
  subnet_id     = aws_subnet.example.id
  ami           = var.ami_id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  instance_type = var.instance_type
  associate_public_ip_address = true
  key_name = "terraform-test"

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("C:\\Users\\chand\\Downloads\\terraform-test.pem")
      host        = self.public_ip
    }
    inline = [
      "sudo yum update",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx"
    ]


  }
}