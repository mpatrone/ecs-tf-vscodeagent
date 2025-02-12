variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the ACM certificate"
  type        = string
  default     = "patrone.click"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}