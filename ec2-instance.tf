 Data source: Get latest AMI ID for Ubuntu OS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Output the retrieved AMI ID
output "latest_ubuntu_ami_id" {
  value = data.aws_ami.ubuntu.id
}
# Local variables
locals {
  user_data = <<-EOT
#!/bin/bash -xe

# System Updates
sudo apt update -y
sudo apt install apache2 -y
EOT

# Define local variable with Cassandra installation script
locals {
  cassandra = <<-EOT
#!/bin/bash -xe

# System Updates
sudo apt update -y
sudo apt install openjdk-8-jre-headless -y
sudo apt-get install curl -y
echo "deb https://debian.cassandra.apache.org 41x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl https://downloads.apache.org/cassandra/KEYS | sudo apt-key add -
sudo apt-get update
sudo apt-get install cassandra -y
EOT
}

# bastion-server in public-subnet-1
resource "aws_instance" "skyage-bastion-server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = "demo"
  subnet_id                   = aws_subnet.public_subnet1.id
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.skyage-bastion-sg.id]
  tags = {
    "Name" = "bastion-server"
  }
}


# two app-servers in private-subnets
resource "aws_instance" "skyage-app-server-1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = "demo"
  subnet_id                   = aws_subnet.private_subnet1.id
  associate_public_ip_address = "false"
  vpc_security_group_ids      = [aws_security_group.skyage-App-SG.id]
  user_data                   = base64encode(local.user_data)
  #user_data = file("deploy-app.sh")
  tags = {
    "Name" = "app-server-1"
  }

}


resource "aws_instance" "skyage-app-server-2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = "demo"
  subnet_id                   = aws_subnet.private_subnet2.id
  associate_public_ip_address = "false"
  vpc_security_group_ids      = [aws_security_group.skyage-App-SG.id]
  user_data                   = base64encode(local.user_data)
  #user_data = file("deploy-app.sh")
  tags = {
    "Name" = "app-server-2"
  }

}

resource "aws_instance" "skyage-database-server-1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.medium"
  key_name                    = "demo"
  subnet_id                   = aws_subnet.skyage-database-subnet-1.id
  associate_public_ip_address = "false"
  vpc_security_group_ids      = [aws_security_group.skyage-App-SG.id]
  user_data                   = base64encode(local.cassandra)
  #user_data = file("deploy-app.sh")
  tags = {
    "Name" = "database-server-1"
  }

}

resource "aws_instance" "skyage-database-server-2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.medium"
  key_name                    = "demo"
  subnet_id                   = aws_subnet.skyage-database-subnet-2.id
  associate_public_ip_address = "false"
  vpc_security_group_ids      = [aws_security_group.skyage-App-SG.id]
  user_data                   = base64encode(local.cassandra)
  #user_data = file("deploy-app.sh")
  tags = {
    "Name" = "database-server-2"
  }

}

