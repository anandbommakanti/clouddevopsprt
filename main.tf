provider "aws" {
    region = "us-east-1"
    access_key = "AKIAWIETO7TV6HQVTR7K"
    secret_key = "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"
}

resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "my_dev_vpc"
        env = "dev"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
        Name = "my-dev-igw"
        env = "dev"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "public_subnet"
        env = "dev"
    }
}

resource "aws_route_table" "custom_route_table" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        name = "custom_route_table"
        env = "dev"
    }
}

resource "aws_route_table_association" "public_subnet_custom_route" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.custom_route_table.id

}

resource "aws_security_group" "allow_app_ports" {
    name = "my-sg-01"
    description = "Allow 22,80,8080"
    vpc_id = aws_vpc.my_vpc.id

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "80"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "8080"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        name = "my-sg-01"
        env = "dev"
    }
}

resource "aws_key_pair" "my-ec2-kp" {
    key_name = "my-ec2-kp"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCw0v1ab7CpTwCz4//gD98iSrq6q9wOZTKJqo3UlnKPI0yFcm+q5iAtBteptBGtKS8AGL4GON7RQFwHOOGtSdr1A5Ww9vuY9bzzlg0+AVi9uYx116XPFmzByoF5Oc1dv6zGEjB7M16pGmSoys8L4XhbK4QPw1/FxKO1jxw5kibHKqEdFFhy17PJCRk7UP7KOarX79khLuDr7SEzJuOiZxOn81Hs2+Stexg6fqYrTW7Q4hralZaa2ZlKh1RGPTVryEnYMsslH8/eMJMx+HBQPjYeMKnZohJcQbl84nSGM1WDH92j8LTiBseegtoPc9tX3SDxCqTghgC/EdewIGx2XsUA1OeIz8E8jrt6n+3xyI/LdNTuOHV/HtP3vkCQ9Tiq7elT92/qb85LqmsZOyvX0/livTj80SuSNcQWR10WTzkjI897pgBMj+GW6FY3ma/SQVeyvgDbQHn37NaN27ZJgRrSFjtAFbX+pW4R6IPjbquxo8wqEZyYDneL7WSGsHUJEZM= anand@LAPTOP-VT2OG7SP"
}

resource "aws_instance" "my-ec2-1-m-dev-pub" {
    ami = "ami-053b0d53c279acc90"
    instance_type = "t2.micro"
    key_name = aws_key_pair.my-ec2-kp.key_name
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.allow_app_ports.id]

    tags = {
        Name = "my-ec2-1-m-dev-pub"
        env = "dev"
    }
}

resource "aws_eip" "eip1" {
    instance = aws_instance.my-ec2-1-m-dev-pub.id
    domain = "vpc"
}

resource "aws_instance" "my-ec2-2-s-dev-pub" {
    ami = "ami-053b0d53c279acc90"
    instance_type = "t2.micro"
    key_name = aws_key_pair.my-ec2-kp.key_name
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.allow_app_ports.id]

    tags = {
        Name = "my-ec2-2-s-dev-pub"
        env = "dev"
    }
}

resource "aws_eip" "eip2" {
    instance = aws_instance.my-ec2-2-s-dev-pub.id
    domain = "vpc"
}

resource "aws_instance" "my-ec2-3-s-dev-pub" {
    ami = "ami-053b0d53c279acc90"
    instance_type = "t2.micro"
    key_name = aws_key_pair.my-ec2-kp.key_name
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.allow_app_ports.id]

    tags = {
        Name = "my-ec2-3-s-dev-pub"
        env = "dev"
    }
}

resource "aws_eip" "eip3" {
    instance = aws_instance.my-ec2-3-s-dev-pub.id
    domain = "vpc"
}

output my-ec2-1-m {
    value = aws_instance.my-ec2-1-m-dev-pub.associate_public_ip_address
}

output my-ec2-2-s {
    value = aws_instance.my-ec2-2-s-dev-pub.associate_public_ip_address
}

output my-ec2-3-s {
    value = aws_instance.my-ec2-3-s-dev-pub.associate_public_ip_address
}