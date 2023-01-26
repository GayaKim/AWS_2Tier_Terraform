output "public_ip" {
  value       = "${aws_instance.web_pub.public_ip}:${var.server_port}"
  description = "The public IP address:port num of the web server"
}

output "db-endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.tf-db.endpoint
}

output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "The domain name of the load balancer"
}
