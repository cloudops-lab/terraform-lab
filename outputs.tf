output "vpc_id" {
  value = aws_vpc.myvpc.id
}

output "instance_ids" {
  value = aws_instance.app[*].id
}

output "instance_private_ips" {
  value = aws_instance.app[*].private_ip
}