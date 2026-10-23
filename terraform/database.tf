
resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "main" {
  name       = "devops-assessment-db-subnets"
  subnet_ids = aws_subnet.private_db[*].id

  tags = {
    Name = "devops-assessment-db-subnets"
  }
}

resource "aws_secretsmanager_secret" "db" {
  name                    = "devops-assessment/mysql-credentials"
  description             = "MySQL credentials for the DevOps assessment"
  recovery_window_in_days = 7

  tags = {
    Project = "devops-assessment"
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = "appadmin"
    password = random_password.db.result
    engine   = "mysql"
    host     = aws_db_instance.main.address
    port     = 3306
    dbname   = "appdb"
  })
}

resource "aws_db_instance" "main" {
  identifier = "devops-assessment-mysql"

  engine         = "mysql"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 30
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "appdb"
  username = "appadmin"
  password = random_password.db.result
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period    = 1
  auto_minor_version_upgrade = true

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "devops-assessment-mysql"
  }
}

output "rds_endpoint" {
  description = "Private endpoint for the MySQL database"
  value       = aws_db_instance.main.address
}
