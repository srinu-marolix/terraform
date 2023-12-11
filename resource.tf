/*1.create vpc
2.create 6 subnets 3 public 3 private in different azs
3.igw for 3 public,nat for 3 private[for nat we required elastic-ip]
4.routetable[routes,rtassosation]
5.elb*/

/* FIRST CREATE VPC AND SUBNETS [2 PUB AND 2 PRVT] AFTER THAT CREATE ROUTE TABLES AND ALSO CREATE ROUTE TABLE ASSOCIATION AND ATTACH THEM TO THE PUBLIC SUBNETS.
AFTER THAT CREATE IGW FOR PUBLIC SUBNETS,NAT GW FOR PRVT SUBNETS ELASTIC IP, LOAD BALANCER.*/


// Creating VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "myvpc"
  }
}

// Creating subnets: 2 public and 2 private
resource "aws_subnet" "SN1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-1b"

  tags = {
    Name = "pub_sn1"
  }
}

resource "aws_subnet" "SN2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-1c"

  tags = {
    Name = "pub_sn2"
  }
}

resource "aws_subnet" "SN3" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-1b"

  tags = {
    Name = "prt_sn1"
  }
}

resource "aws_subnet" "SN4" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-1c"

  tags = {
    Name = "prt_sn2"
  }
}

# creating IGW for public subnets

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw1"
  }
}

# route table creation

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "rt_pub_sub"
  }
}

# route table association

resource "aws_route_table_association" "b" {
  route_table_id = aws_route_table.RT.id
  subnet_id      = aws_subnet.SN1.id
}

resource "aws_route_table_association" "a" {
  route_table_id = aws_route_table.RT.id
  subnet_id      = aws_subnet.SN2.id
}

# creating EIP 

resource "aws_eip" "nat_gateway" {
  domain   = "vpc"
}

resource "aws_eip" "nat_gateway1" {
  domain   = "vpc"
}
# creating NGW

resource "aws_nat_gateway" "NGW" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.SN3.id

  tags = {
    Name = "ngw1"
  }
  }
  
 resource "aws_nat_gateway" "NGW1" {
  allocation_id = aws_eip.nat_gateway1.id
  subnet_id     = aws_subnet.SN4.id

  tags = {
    Name = "ngw1"
  } 
  }
  
 # creating load balancer
  
  resource "aws_lb" "test" {
  name               = "loabbalncer"
  subnets            = [aws_subnet.SN1.id,aws_subnet.SN2.id]
  }
  
  