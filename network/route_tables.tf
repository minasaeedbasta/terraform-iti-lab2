resource "aws_route_table" "route_tables" {
  count=6
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = (count.index == 0 || count.index == 2  || count.index == 4  ) ? aws_internet_gateway.igw.id : aws_nat_gateway.ngw.id
  }
  tags = {
    Name = "${var.subnets[count.index].name}_rtbl"
  }
}

resource "aws_route_table_association" "public1_rt_associate" {
  subnet_id      = aws_subnet.subnets["public1"].id
  route_table_id = aws_route_table.route_tables[0].id
}
resource "aws_route_table_association" "public2_rt_associate" {
  subnet_id      = aws_subnet.subnets["public2"].id
  route_table_id = aws_route_table.route_tables[2].id
}
resource "aws_route_table_association" "public3_rt_associate" {
  subnet_id      = aws_subnet.subnets["public3"].id
  route_table_id = aws_route_table.route_tables[4].id
}

resource "aws_route_table_association" "private1_rt_associate" {
  subnet_id      = aws_subnet.subnets["private1"].id
  route_table_id = aws_route_table.route_tables[1].id
}
resource "aws_route_table_association" "private2_rt_associate" {
  subnet_id      = aws_subnet.subnets["private2"].id
  route_table_id = aws_route_table.route_tables[3].id
}
resource "aws_route_table_association" "private3_rt_associate" {
  subnet_id      = aws_subnet.subnets["private3"].id
  route_table_id = aws_route_table.route_tables[5].id
}

# resource "aws_route_table" "rtbls" {
#   for_each = { for subnet in var.subnets : subnet.name => subnet }
#   vpc_id   = aws_vpc.main_vpc.id

#   tags = {
#     Name = "${each.value.name}_rtbl"
#   }
# }

# resource "aws_route" "routes" {
#   for_each               = aws_route_table.rtbls
#   route_table_id         = each.value.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = each.value.tags.Name == "public" ? aws_internet_gateway.igw.id : aws_nat_gateway.ngw.id
# }

# resource "aws_route_table_association" "rtbl_associations" {
#   for_each       = aws_subnet.subnets
#   subnet_id      = each.value.id
#   route_table_id = aws_route_table.rtbls[each.value.].id
# }