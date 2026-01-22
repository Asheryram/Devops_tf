# AWS Secrets Manager for storing sensitive data

# Create secret for database password
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project}-${var.environment}-db-password"
  description             = "Database password for ${var.project}"
  recovery_window_in_days = 7
  tags                    = var.tags
}

# Store the actual secret value
resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    engine   = "mysql"
    host     = var.db_host
    port     = var.db_port
    dbname   = var.db_name
  })
}

# Create secret for database credentials (alternative simpler format)
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project}-${var.environment}-db-credentials"
  description             = "Database credentials for ${var.project}"
  recovery_window_in_days = 7
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}
