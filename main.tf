resource "aws_vpc" "mtc_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}


resource "aws_subnet" "mtc_public_subnet" {
  vpc_id                  = aws_vpc.mtc_vpc.id
  cidr_block              = "10.123.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "dev-public"
  }
}


resource "aws_internet_gateway" "mtc_internet_gateway" {
#Allows instance to access internet; Internet gateway is pointed to VPC where instance is resided
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "dev-igw"
  }
}


resource "aws_route_table" "mtc_public_rt" {
#Set of rules defining where network traffic goes from subnet/vpc
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "dev-public-rt"
  }
}


resource "aws_route" "default_route" {
/*
Allows particular resource access to all ports in all ip; 
essential when internet access is given to resource
aws_route is defined separately instead of putting inside the aws_route_table block
*/
  route_table_id         = aws_route_table.mtc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mtc_internet_gateway.id
}


resource "aws_route_table_association" "mtc_public_assoc" {
#Links route table to specific subnet where instance is located
  subnet_id      = aws_subnet.mtc_public_subnet.id
  route_table_id = aws_route_table.mtc_public_rt.id
}


resource "aws_security_group" "mtc_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.mtc_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/32"] #put your ip address here to allow instance to only accept your system
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #Allows instance to access all ports; helps since internet gateway is used
  }
}


resource "aws_key_pair" "mtc_auth" {
#aws key pair is used to specify the particular key used to access the instance through ssh
  key_name   = "mtckey"
  public_key = file("~/.ssh/mtckey.pub")
  depends_on = [null_resource.ssh]
}

resource "null_resource" "ssh" {
  provisioner "local-exec" {
    command = "ssh-keygen -t ed25519 -f ~/.ssh/mtckey -N ''"
  }
  triggers = {
    create_run = file("~/.ssh/mtckey") == "" ? "1" : "0"
  }
/*
Checks if ssh key is generated; if not would generate one. 
This ensures that multiple keys are not wastefully generated
*/
}


resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.mtc_auth.key_name
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id              = aws_subnet.mtc_public_subnet.id
  user_data              = file("userdata.tpl") #Code file to be run upon instance's initialization

  root_block_device {
    volume_size = 10 #size of instance in GB
  }

  tags = {
    Name = "dev-node"
  }

  provisioner "local-exec" {
    command = templatefile("linux-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "~/.ssh/mtckey"
    })
    interpreter = ["bash", "-c"]
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ~/.ssh/config"
  }

  depends_on = [null_resource.ssh]

}