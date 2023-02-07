module "cloudfront_log_storage" {
  count = var.create_logs_bucket ? 1 : 0
  source = "cloudposse/s3-log-storage/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "0.28.0"
  name                     = var.logs_bucket
  acl                      = "log-delivery-write"
  standard_transition_days = 30
  glacier_transition_days  = 90
  expiration_days          = 180
}

resource "aws_cloudfront_distribution" "this" {

  origin {
    domain_name = var.alb_domain_name
    origin_id   = var.alb_origin_id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.comment

  logging_config {
    include_cookies = false
    bucket          = var.create_logs_bucket ? module.cloudfront_log_storage[0].bucket_domain_name : "${var.logs_bucket}.s3.amazonaws.com"
    prefix          = var.logs_prefix
  }

  aliases = var.app_domain_names

  default_cache_behavior {
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD"]
    target_origin_id           = var.alb_origin_id
    response_headers_policy_id = length(var.response_headers_policy_id) > 0 ? var.response_headers_policy_id : ""

    forwarded_values {
      query_string = true
      headers        = ["*"]
      cookies {
        forward = "all"
      }
    }

    dynamic "lambda_function_association" {
      for_each = var.lambda_association == null ? [] : var.lambda_association
      content {
        event_type = lambda_function_association.value.event_type
        include_body = lambda_function_association.value.include_body
        lambda_arn = lambda_function_association.value.lambda_arn
      }
    }

    dynamic "function_association" {
      for_each = var.function_association == null ? [] : var.function_association
      content {
        event_type = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
    compress               = var.compress
  }

  price_class = var.price_class

  restrictions {
    dynamic "geo_restriction" {
      for_each = var.geo_restriction ? [] : [1]
      content {
         restriction_type = "none"
      }
    }

    dynamic "geo_restriction" {
      for_each = var.geo_restriction ? [1] : []
      content {
         restriction_type = "whitelist"
         locations        = var.restriction_locations
      }
    }

  }


  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    minimum_protocol_version = var.minimum_protocol_version
    ssl_support_method = "sni-only"
  }

}

resource "aws_route53_record" "web_record" {
  for_each = toset(var.app_domain_names)
  zone_id = var.zone_id
  name    = "${each.value}."
  type    = "A"

  alias {
    name                   = replace(aws_cloudfront_distribution.this.domain_name, "/[.]$/", "")
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_cloudfront_distribution.this]
}