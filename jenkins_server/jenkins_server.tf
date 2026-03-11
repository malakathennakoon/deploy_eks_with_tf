provider "aws" {
  region = "eu-west-3" # Change to your preferred region
}

# 1. Create a Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-docker-sg"
  description = "Allow SSH and Jenkins traffic"

  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # For better security, replace with your IP: "x.x.x.x/32"
  }

  # Jenkins UI
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# get ami for aws instance in eu-west-3 region
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

# 2. Deploy EC2 Instance
resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.medium"             # Recommended for Jenkins
  key_name      = "jenkins-key"    # Replace with your actual key pair name

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user

              mkdir -p /home/ec2-user/jenkins_home
              chown -R 1000:1000 /home/ec2-user/jenkins_home

              docker run -d \
                --name jenkins \
                -p 8080:8080 -p 50000:50000 \
                -v /home/ec2-user/jenkins_home:/var/jenkins_home \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -v $(which docker):/usr/bin/docker \
                -e JAVA_OPTS="-Xms1g -Xmx3g"
                --restart always \
                jenkins/jenkins:lts
              EOF

  tags = {
    Name = "Jenkins-Docker-Server"
  }
}

# 3. Output the Public IP
output "jenkins_url" {
  value = "http://${aws_instance.jenkins_server.public_ip}:8080"
}