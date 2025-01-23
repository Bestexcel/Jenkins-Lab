#Creating local name for my resource
/*  
Purpose: This block defines a local variable name
 with the value "pmo", which can be used throughout the configuration
*/

locals {
  name = "pmo"
}


#Creating a RSA key of size 4096 bits
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Creating public & private key
//public key on aws
resource "aws_key_pair" "key" {
  key_name   = "pmo-jenkins-key"
  public_key = tls_private_key.key.public_key_openssh
}

//private key on local file
resource "local_file" "key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "pmo-jenkins-key.pem"
  file_permission = 400
}

#Creating Security group


#maven security group

resource "aws_security_group" "pmo-maven-sg" {
  name        = "pmo-maven-server"
  description = "pmo-maven-server-security group"

  ingress {
    description = "ssh from vpc"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allcidr]
  }

  tags = {
    name = "$(locals.name)-pmo-maven-sg"
  }
}


#creating production security group
resource "aws_security_group" "pmo-prod-sg" {
  name        = "pmo-prod"
  description = "instance_security_group"

  ingress {
    description = "ssh from vpc"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

  ingress {
    description = "http from vpc"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allcidr]
  }

  tags = {
    name = "$(locals.name)-pmo-prod-sg"
  }
}

#Create maven instance
resource "aws_instance" "pmo-maven" {
  ami                         = var.redhat //redhat
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.pmo-maven-sg.id]
  user_data                   = file("./userdata.sh")

  tags = {
    name = "$(locals.name)-pmo-maven-server"
  }
}

#Create jenkins instance
#resource "aws_instance" "pmo-jenkins" {
# ami                        = "ami-0343a21cd4b9d8ee8" //redhat
#instance_type               = "t2.medium"
#associate_public_ip_address = true
#key_name                    = aws_key_pair.key.id
#vpc_security_group_ids      = [aws_security_group.pmo-jenkins-sg.id]
#user_data                   = file("./userdata1.sh")

#tags = {
#name ="$(locals.name)-pmo-jenkins-server"
#}
#}


#Create production instance
resource "aws_instance" "pmo-prod" {
  ami                         = var.redhat //redhat
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.pmo-prod-sg.id]
  user_data                   = file("./userdata2.sh")
  tags = {
    name = "$(locals.name)-pmo-host-server"
  }
}




