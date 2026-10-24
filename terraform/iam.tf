
resource "aws_iam_role" "app" {
  name = "devops-assessment-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "devops-assessment"
  }
}

resource "aws_iam_role_policy" "app_secrets" {
  name = "devops-assessment-read-db-secret"
  role = aws_iam_role.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.db.arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "app" {
  name = "devops-assessment-instance-profile"
  role = aws_iam_role.app.name
}
