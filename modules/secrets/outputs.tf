output "db_password_secret_id" {
  value       = aws_secretsmanager_secret.db_password.id
  description = "The ID of the database password secret"
}

output "db_password_secret_arn" {
  value       = aws_secretsmanager_secret.db_password.arn
  description = "The ARN of the database password secret"
}

output "db_password_secret_version_id" {
  value       = aws_secretsmanager_secret_version.db_password.id
  description = "The version ID of the database password secret"
}

output "db_credentials_secret_id" {
  value       = aws_secretsmanager_secret.db_credentials.id
  description = "The ID of the database credentials secret"
}

output "db_credentials_secret_arn" {
  value       = aws_secretsmanager_secret.db_credentials.arn
  description = "The ARN of the database credentials secret"
}

output "db_credentials_secret_version_id" {
  value       = aws_secretsmanager_secret_version.db_credentials.id
  description = "The version ID of the database credentials secret"
}
