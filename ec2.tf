resource "aws_spot_instance_request" "jd-terrafrom-ec2" {
  count = var.public_subnet_count
  ami = "ami-04581fbf744a7d11f"
  
  instance_type = "t3.micro"
  key_name = "Jason_D"
  subnet_id = element(aws_subnet.JD-subnet-public.*.id, count.index)
  vpc_security_group_ids = [aws_security_group.JD-VPC-Main-SG.id]
  tags = {
    "Name" = "${var.default_tags.env}-EC2"
    "OtherTag" = "OtherTag"
   } 
}