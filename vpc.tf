# Create terrakube vpc
resource "aws_vpc" "terrakube_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "terrakube_vpc"
  }
}
# Create internet gateway
resource "aws_internet_gateway" "terrakube_igw" {
  vpc_id = aws_vpc.terrakube_vpc.id

  tags = {
    Name = "terrakube_vpc-igw"
  }
}

# Create public subnets
resource "aws_subnet" "terrakube_public_subnets" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.terrakube_vpc.id
  cidr_block = cidrsubnet(var.terrakube_public_subnet_range,2,count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index%length(data.aws_availability_zones.available.names))

  tags = {
    Name = "terrakube_public-subnet-${element(data.aws_availability_zones.available.names, count.index%length(data.aws_availability_zones.available.names))}"
  }
}

# Add default routes to public subnet RTR
resource "aws_route_table" "terrakube_public_rt" {
  vpc_id = aws_vpc.terrakube_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terrakube_igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.terrakube_igw.id
  }

  tags = {
    Name = "terrakube-route-table"
  }
}

# Associate RTR to public subnets
resource "aws_route_table_association" "terrakube_public_rt_association" {
  count = length(data.aws_availability_zones.available.names)
  subnet_id = element(aws_subnet.terrakube_public_subnets.*.id,count.index)
  route_table_id = aws_route_table.terrakube_public_rt.id
}