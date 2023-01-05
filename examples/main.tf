resource "aws_cloudfront_response_headers_policy" "example_headers_policy" {
  name = "example.${var.tld}_policy"

  custom_headers_config {
    items {
      header   = "X-Robots-Tag"
      override = true
      value    = "noindex"
    }

  }
}

module lb-cloudfront {

  source = "github.com/silksh-terraform-modules/terraform-aws-cloudfront-alb?ref=v0.0.1"

  alb_domain_name = aws_lb.external.dns_name
  
  app_domain_names = [
    "front.${var.tld}",
  ]

  ## bucket for logs
  ## define as full domain name if you want to use bucket created elsewhere
  ## and define `create_logs_bucket` to false below
  logs_bucket = "${var.project_full_name}-cloudfront-logs-${var.env_name}"
  ## do we have to create logs bucket
  create_logs_bucket = true
  alb_origin_id = "ALBOrigin"
  acm_certificate_arn = data.terraform_remote_state.infra.outputs.ssl_cert_us_certificate_arn
  zone_id = data.terraform_remote_state.infra.outputs.ssl_cert_us_zone_id
  comment = "cloudfront endpoint for ALB"
  ## use if defined `example_headers_policy` earlier
  response_headers_policy_id = aws_cloudfront_response_headers_policy.example_headers_policy.id

  # web_acl_id          = data.terraform_remote_state.cloudfront.outputs.waf_web_acl_arn

}