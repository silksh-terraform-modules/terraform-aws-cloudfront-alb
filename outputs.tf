output "zone_id" {
  value = aws_cloudfront_distribution.this.hosted_zone_id
}

output "domain_name" {
  # value = "${aws_cloudfront_distribution.this.domain_name}"
  value = replace(aws_cloudfront_distribution.this.domain_name, "/[.]$/", "")
}

# output "app_domain_names" {
#   # value = "${aws_cloudfront_distribution.this.domain_name}"
#   value = replace(aws_route53_record.web_record["*"].name, "/[.]$/", "")
# }