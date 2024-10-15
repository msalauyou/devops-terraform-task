terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

data "aws_ami" "ubuntu" {
    owners = ["099720109477"]
    most_recent = true
    
    filter {
        name = "name"
        values = [var.ubuntu_ami_name]
    }
}

resource "aws_instance" "ubuntu" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    vpc_security_group_ids = [ aws_security_group.ubuntu_sg.id ]
    subnet_id = aws_subnet.public.id
    associate_public_ip_address = true

    user_data = file("user_data.sh")
    
    tags = {
        Name = "Ubuntu-Instance"
    }
}

resource "aws_security_group" "ubuntu_sg" {
    name        = "allow_icmp_tcp"
    description = "Allow ICMP, TCP/22, 80, 443 and any outgoing access"
    vpc_id      = aws_vpc.main.id

    tags = {
        Name = "allow_icmp_tcp"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_443" {
    security_group_id = aws_security_group.ubuntu_sg.id
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = 443
    ip_protocol       = "tcp"
    to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_80" {
    security_group_id = aws_security_group.ubuntu_sg.id
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = 80
    ip_protocol       = "tcp"
    to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_22" {
    security_group_id = aws_security_group.ubuntu_sg.id
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp" {
    security_group_id = aws_security_group.ubuntu_sg.id
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = 8
    ip_protocol       = "icmp"
    to_port           = 0
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
    security_group_id = aws_security_group.ubuntu_sg.id
    cidr_ipv4         = "0.0.0.0/0"
    ip_protocol       = "-1"
}

resource "aws_vpc" "main" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"
    
    tags = {
        Name = "My main VPC"
    }
}

resource "aws_subnet" "public" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    
    tags = {
        Name = "Public"
    }
}

resource "aws_subnet" "private" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    
    tags = {
        Name = "Private"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id
    
    tags = {
        Name = "My VPC IG"
    }
}

resource "aws_route_table" "second_rt" {
    vpc_id = aws_vpc.main.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
    
    tags = {
        Name = "My 2nd Route Table"
    }
}

resource "aws_route_table_association" "public_subnet_asso" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.second_rt.id
}

data "aws_ami" "amazon_linux" {
    owners = ["137112412989"]
    most_recent = true
    
    filter {
        name = "name"
        values = [var.amazon_linux_ami_name]
    }
}

resource "aws_instance" "amazon_linux" {
    ami           = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.private.id
    
    tags = {
        Name = "Amazon-Linux-Instance"
    }
}

resource "aws_security_group" "amazon_linux_sg" {
    name        = "allow_internal_icmp_tcp"
    description = "Allow internal ICMP, TCP/22, 80, 443"
    vpc_id      = aws_vpc.main.id
    
    tags = {
        Name = "allow_internal_icmp_tcp"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_internal_tcp_443" {
    security_group_id = aws_security_group.amazon_linux_sg.id
    cidr_ipv4         = aws_vpc.main.cidr_block
    from_port         = 443
    ip_protocol       = "tcp"
    to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_internal_tcp_80" {
    security_group_id = aws_security_group.amazon_linux_sg.id
    cidr_ipv4         = aws_vpc.main.cidr_block
    from_port         = 80
    ip_protocol       = "tcp"
    to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_internal_tcp_22" {
    security_group_id = aws_security_group.amazon_linux_sg.id
    cidr_ipv4         = aws_vpc.main.cidr_block
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_internal_icmp" {
    security_group_id = aws_security_group.amazon_linux_sg.id
    cidr_ipv4         = aws_vpc.main.cidr_block
    from_port         = 8
    ip_protocol       = "icmp"
    to_port           = 0
}

resource "aws_vpc_security_group_egress_rule" "allow_internal_traffic_ipv4" {
    security_group_id = aws_security_group.amazon_linux_sg.id
    cidr_ipv4         = aws_vpc.main.cidr_block
    ip_protocol       = "-1"
}
