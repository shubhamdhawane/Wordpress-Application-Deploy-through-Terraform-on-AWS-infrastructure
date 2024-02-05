#####################################
# security group for bastion-server
#####################################
resource "aws_security_group" "skyage-bastion-sg" {
  name        = "bastion-sg"
  description = "Allow port 22 from anywhere"
  vpc_id      = aws_vpc.skyage.id
  tags = {
    "Name" = "sg-for-bastion-server"
  }
  ingress {
    description = "Allow port 22 from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


############################
# security group for ALB
############################
resource "aws_security_group" "skyage-ALB-SG" {
  name        = "ALB-SG"
  description = "Allow port 80 and 443 from anywhere"
  vpc_id      = aws_vpc.skyage.id
  tags = {
    "Name" = "sg-for-skyage-alb"
  }
  ingress {
    description = "Allow port 80 from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  /*
  ingress {
    description = "Allow port 443 from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  */
  egress {
    description = "Allow All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


###################################
# security group for app-servers
###################################
resource "aws_security_group" "skyage-App-SG" {
  name        = "App-SG"
  description = "Allow port 22 from bastion-sg and 80 from ALB-SG"
  vpc_id      = aws_vpc.skyage.id
  tags = {
    "Name" = "sg-for-app-servers"
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.skyage-bastion-sg.id]
    description     = "allow-trrafic-from-bastion-sg-only"
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.skyage-ALB-SG.id]
    description     = "allow-trrafic-from-ALB-SG-only"
  }
  /*
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.skyage-ALB-SG.id]
    description     = "allow-trrafic-from-ALB-SG-only"
  }
  */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow All"
  }
}


###################################
# security group for nosql-server
###################################
resource "aws_security_group" "skyage-DB-SG" {
  name        = "DB-SG"
  description = "Allow port 7000 from App-SG only"
  vpc_id      = aws_vpc.skyage.id
  tags = {
    "Name" = "sg-for-nosql-server"
  }
  ingress {
    from_port       = 7000
    to_port         = 7000
    protocol        = "tcp"
    security_groups = [aws_security_group.skyage-App-SG.id]
    description     = "allow-trrafic-from-App-SG-only"
  }

  ingress {
    from_port       = 7000
    to_port         = 7000
    protocol        = "tcp"
    security_groups = [aws_security_group.skyage-App-SG.id]
    description     = "allow-trrafic-from-App-SG-only"
  }
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.skyage-App-SG.id]
    description     = "allow-trrafic-from-App-SG-only"
  }
  ingress {
    from_port       = 7001
    to_port         = 7001
    protocol        = "tcp"
    security_groups = [aws_security_group.skyage-App-SG.id]
    description     = "allow-trrafic-from-App-SG-only"
  }
  ingress {
    from_port       = 9042
    to_port         = 9042
    protocol        = "tcp"
    security_groups = [aws_security_group.skyage-App-SG.id]
    description     = "allow-trrafic-from-App-SG-only"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow All"
  }
}
