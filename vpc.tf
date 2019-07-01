# Create terrakube vpc
resource "aws_vpc" "terrakube-vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "terrakube-vpc"
  }
}
# Create internet gateway
resource "aws_internet_gateway" "terrakube-igw" {
  vpc_id = "${aws_vpc.terrakube-vpc.id}"

  tags {
    Name = "terrakube-vpc-igw"
  }
}

# Create public subnets
resource "aws_subnet" "terrakube-public-subnets" {
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.terrakube-vpc.id}"
  cidr_block = "${cidrsubnet(var.terrakube-public-subnet-range,2,count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index%length(data.aws_availability_zones.available.names))}"

  tags {
    Name = "terrakube-public-subnet-${element(data.aws_availability_zones.available.names, count.index%length(data.aws_availability_zones.available.names))}"
  }
}

resource "aws_subnet" "terrakube-private-subnets" {
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.terrakube-vpc.id}"
  cidr_block = "${cidrsubnet(var.terrakube-private-subnet-range,2,count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index%length(data.aws_availability_zones.available.names))}"

  tags {
    Name = "terrakube-private-subnet-${element(data.aws_availability_zones.available.names, count.index%length(data.aws_availability_zones.available.names))}"
  }
}

# Add default routes to public subnet RTR
resource "aws_route_table" "terrakube-public-rt" {
  vpc_id = "${aws_vpc.terrakube-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terrakube-igw.id}"
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = "${aws_internet_gateway.terrakube-igw.id}"
  }

  tags {
    Name = "terrakube-route-table"
  }
}

# Associate RTR to public subnets
resource "aws_route_table_association" "terrakube-public-rt-association" {
  count = "${length(data.aws_availability_zones.available.names)}"
  subnet_id = "${element(aws_subnet.terrakube-public-subnets.*.id,count.index)}"
  route_table_id = "${aws_route_table.terrakube-public-rt.id}"
}
