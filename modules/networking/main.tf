resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = merge(var.tags, {
    Name = "${var.project}-vpc"
  })
}


resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id


  tags = merge(var.tags, {
    Name = "${var.project}-igw"
  })
}


resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true


  tags = merge(var.tags, {
    Name = "public-${count.index + 1}"
    Tier = "public"
  })
}


resource "aws_subnet" "app" {
  count             = 2
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]


  tags = merge(var.tags, {
    Name = "app-${count.index + 1}"
    Tier = "app"
  })
}

resource "aws_subnet" "db" {
  count             = 2
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]


  tags = merge(var.tags, {
    Name = "db-${count.index + 1}"
    Tier = "db"
  })
}


resource "aws_eip" "nat" {
  domain = "vpc"


  tags = merge(var.tags, {
    Name = "${var.project}-nat-eip"
  })
}


resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id


  tags = merge(var.tags, {
    Name = "${var.project}-nat"
  })
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }


  tags = merge(var.tags, {
    Name = "public-rt"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id


  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }


  tags = merge(var.tags, {
    Name = "private-rt"
  })
}


resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private_app" {
  count          = 2
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "private_db" {
  count          = 2
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.private.id
}
