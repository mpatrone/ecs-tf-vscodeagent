output "cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "service_connect_namespace_id" {
  description = "The ID of the service connect namespace"
  value       = aws_service_discovery_http_namespace.tf_ns.id
}

output "service_connect_namespace_arn" {
  description = "The ARN of the service connect namespace"
  value       = aws_service_discovery_http_namespace.tf_ns.arn
}

output "task_security_groups" {
  description = "Map of security group IDs for the tasks"
  value = {
    public  = aws_security_group.public_task.id
    private = aws_security_group.private_task.id
  }
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task.arn
}

output "execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_execution.arn
}