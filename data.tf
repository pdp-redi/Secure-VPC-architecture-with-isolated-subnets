# Data source to fetch available availability zones in the ap-south-2 region 
data "aws_availability_zones" "available" {
  state = "available"
}