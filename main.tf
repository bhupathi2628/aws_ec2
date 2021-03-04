
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.5.0"
    }
  }
}
provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "amazon" {
    count = 1
    ami = "ami-0915bcb5fa77e4892"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public_subnet.id
    security_groups = ["${aws_security_group.ec2_sg.id}"]
    key_name = "navya"
    user_data = <<-EOF
                #!/bin/sh
                #installing jenkins on amazon-linux 2
                sudo amazon-linux-extras install java-openjdk11 -y
                sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
                sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
                sudo yum install jenkins -y
                sudo systemctl start jenkins
                sudo systemctl enable jenkins
                systemctl status jenkins

                sudo yum update -y
                sudo yum install git -y

                
                sudo wget https://releases.hashicorp.com/terraform/0.14.5/terraform_0.14.5_linux_amd64.zip
                unzip terraform_0.14.5_linux_amd64.zip

                sudo mv terraform /usr/bin

                EOF

    tags = {
        Name = "amazon-linux"
    }
}

resource "aws_key_pair" "ec2_key" {
    key_name = "navya"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAoNFrn2H2vYdNq6uhnq9zpGTz/CHxuBxY1ekcM69b3qqwDEL7nXbYmwT99R42bkVWrP14pRo9EFMB+4deGPuOxPfvz+RW23ZC0iBuRKlNwhIns/FXI2Dt6e3NzeX8rtOY/hVByb9KbpvIikVXq11s5CNUpfa8lorWIPjBDAswIa7sMvoJ9/DQWSuBNgJso3Jk48QuqY9WNl1a1NWwgX6qhOuIt9oHdCv6pdp2aJEvJtOsrmQcaSAUBR9W35FhhO6E6P2cpcys8mbCVTnP/sZFG++n4p/Z9oo/QEP3X0+8pCMPhVO87UjbeWGapkh4hGtEY8quOLdjo6Vtler/GlcW1Q== rsa-key-20210227"
}
resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_hostnames = true
    tags = {
        Name = "myvpc"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
       Name = "public_subnet"
    }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
      Name = "myigw"
  }
}


resource "aws_route_table" "public_route" {
    vpc_id = aws_vpc.my_vpc.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
      Name = "routetable"
  }
}

resource "aws_route_table_association" "my_route" {

  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}


resource "aws_security_group" "ec2_sg" {
   vpc_id = aws_vpc.my_vpc.id
   ingress  {
     cidr_blocks = ["49.207.58.33/32"]
     from_port = 0
     protocol = -1
     to_port = 0
   } 
   egress  {
     cidr_blocks = ["0.0.0.0/0"]
     from_port = 0
     protocol = -1
     to_port = 0
   } 
   tags = {
       Name = "ec2_sg"
   }
}

resource "aws_ebs_volume" "custom" {
  size = 100
  type = "gp3"
  availability_zone = "us-east-1a"
}


resource "aws_ebs_snapshot" "new_snap" {
    volume_id = aws_ebs_volume.custom.id  
}

resource "aws_volume_attachment" "attachment" {
  device_name = "/dev/sdf"
   volume_id = aws_ebs_volume.custom.id 
   instance_id = aws_instance.amazon[0].id
}
