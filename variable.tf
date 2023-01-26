#instance id
variable "image_id" {
  description = "ami"
  type        = string
  default     = ""
}

#instance type
variable "instance_type" {
  description = "The type for instance"
  type        = string
  default     = "t2.micro"
}

#Server Port
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

#VM Security Group
variable "instance_security_group_name" {
  description = "The name of the security group for EC2 Instance"
  type        = string
  default     = "allow_http_ssh_instance"
}

#DB Security Group
variable "db_security_group_name" {
  type    = string
  default = "allow_mysql_db"
}

#lb name
variable "alb_name" {
  description = "The name of the ALB"
  type        = string
  default     = "tf-alb"
}

variable "alb_security_group_name" {
  description = "The name of the security group for the ALB"
  type        = string
  default     = "allow_http_alb"
}
