provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAZJFIKREBR7ORWUFU"
  secret_key = "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"
}

resource "aws_vpc" "myVpc" {
  cidr_block = "20.0.0.0/16"
  instance_tenancy = "default"
}


# variable "public_subnet_cidrs" {
#  type        = list(string)
#  description = "Public Subnet CIDR values"
#  default     = ["10.0.1.0/24"]
# }

resource "aws_subnet" "public_subnet" {
  # count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.myVpc.id
  cidr_block = "20.0.1.0/24"
  
}
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVpc.id
  tags = {
    Name = "Project VPC IG"
  }
}
resource "aws_route_table" "myRoutes" {
  vpc_id = aws_vpc.myVpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }
}
resource "aws_route_table_association" "myRoutesAssociations" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.myRoutes.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.myVpc.id

  ingress { 
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "ec2_01" {
  ami = "ami-0574da719dca65348"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet.id
  security_groups = ["${aws_security_group.allow_all.id}"]

  key_name = "KeyPair"
  associate_public_ip_address = true
  user_data = "${file("filename.sh")}"
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt update -y",
	#     "sudo apt install ansible -y"
  #   ]
  #   connection {
  #       type                = "ssh"
  #       user                = "ubuntu"
  #       private_key         = file("./KeyPair.pem")
  #       host                = coalesce(self.public_ip,self.private_ip)
        
  #   }
  # }
  tags = {
    Name = "Ansible"
  }
}

