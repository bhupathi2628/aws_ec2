 output "aws_vpc_id" {
   description = "this output of vpc id"
   value       = aws_vpc.my_vpc.id
 }

 output "aws_publicsubnet_id" {
   description = "this output of publicsubnet"
   value       = aws_subnet.public_subnet.id
 }

 output "aws_security_gr_id" {
   description = "this output of security groups"
   value       = aws_security_group.ec2_sg.id
 }