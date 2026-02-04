provider "aws" {
  region = "eu-west-3" # Paris
}

data "aws_ami" "ubuntu" {
  most_recent = true
    owners      = ["099720109477"] # Canonical

    filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "registery_key_terraform"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
    filename = "${path.module}/registry_key_terraform.pem"
    content  = tls_private_key.pk.private_key_pem
    file_permission = "0400"
}

resource "aws_security_group" "registry_sg" {
  name        = "registry_sg_simple"
  description = "Allow SSH, HTTP access and Registry (port 5000)"

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Registry"
        from_port   = 5000
        to_port     = 5000
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

resource "aws_instance" "registry_server" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"
    key_name = aws_key_pair.generated_key.key_name

    vpc_security_group_ids = [aws_security_group.registry_sg.id]

    root_block_device {
        volume_size = 20
        volume_type = "gp3"
    }

    tags = {
        Name = "Terraform-Registry-Server"
    }
}

output "instance_ip" {
    value = aws_instance.registry_server.public_ip
}