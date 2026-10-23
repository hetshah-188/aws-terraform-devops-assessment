
resource "aws_acm_certificate" "site" {
  domain_name       = "devops.life4u.me"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name    = "devops-assessment-certificate"
    Project = "devops-assessment"
  }
}

output "acm_dns_validation_records" {
  description = "Add these DNS validation records at your domain DNS provider"
  value = [
    for dvo in aws_acm_certificate.site.domain_validation_options : {
      domain = dvo.domain_name
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  ]
}
