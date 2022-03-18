#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "plana-ch2-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = map(
    "Name", "plana-ch2-vpc",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "plana-ch2-subnet" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.plana-ch2-vpc.id

  tags = map(
    "Name", "plana-ch2-subnet",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "plana-ch2-gateway" {
  vpc_id = aws_vpc.plana-ch2-vpc.id

  tags = {
    Name = "plana-ch2-gateway"
  }
}

resource "aws_route_table" "plana-ch2-route" {
  vpc_id = aws_vpc.plana-ch2-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.plana-ch2-gateway.id
  }
}

resource "aws_route_table_association" "plana-ch2-route-table" {
  count = 2

  subnet_id      = aws_subnet.plana-ch2-subnet.*.id[count.index]
  route_table_id = aws_route_table.plana-ch2-route.id
}
