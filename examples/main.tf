module lb-cloudfront {

  source = "github.com/silksh-terraform-modules/terraform-aws-cloudfront-alb?ref=v0.0.1"

  alb_domain_name = aws_lb.external.dns_name
  
  app_domain_names = [
    "front.${var.tld}",
  ]

  # bucket logów stworzony wcześniej
  logs_bucket = "${var.project_full_name}-cloudfront-logs-${var.env_name}"
  alb_origin_id = "ALBOrigin"
  acm_certificate_arn = data.terraform_remote_state.infra.outputs.ssl_cert_us_certificate_arn
  zone_id = data.terraform_remote_state.infra.outputs.ssl_cert_us_zone_id
  comment = "cloudfront endpoint for ALB"
  logs_prefix = "front.${var.tld}"

  # web_acl_id          = data.terraform_remote_state.cloudfront.outputs.waf_web_acl_arn

}