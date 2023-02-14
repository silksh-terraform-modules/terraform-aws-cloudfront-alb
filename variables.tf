
variable "logs_bucket" {
  default = ""
}

variable "alb_origin_id" {
  default = ""
}

variable "alb_domain_name" {
  default = ""
}

variable "app_domain_names" {
  default = [""]
}

variable "min_ttl" {
  default = 0
}

variable "default_ttl" {
  default = 60
}

variable "max_ttl" {
  default = 300
}

variable "compress" {
  default = false
}

variable "price_class" {
  default = "PriceClass_All"
}

## domyslnie data.terraform_remote_state.domain_cert_us.outputs.certificate_arn
variable "acm_certificate_arn" {
  default = ""
}

## data.terraform_remote_state.domain_cert_us.outputs.zone_id
variable "zone_id" {
  default = ""
}

variable "comment" {
  default = "created by SilkSH with terraform"
}

variable "minimum_protocol_version" {
  default = "TLSv1.2_2018"
}

variable "geo_restriction" {
  type = bool
  default = false
}

variable "restriction_locations" {
  default = ["PL", "US", "GB", "DE", "CA"]
}

variable "logs_prefix" {
  default = "cloudfront4alb"
}

variable "create_logs_bucket" {
  default = false
  description = "do we have to create logs bucket"
}

variable "response_headers_policy_id" {
  default = ""
}

variable "lambda_association" {
  type = list(object({
    event_type = string,
    include_body = bool,
    lambda_arn = string
  }))

  default = null
  
}

variable "function_association" {
  type = list(object({
    event_type = string,
    function_arn = string
  }))

  default = null
  
}

variable "ordered_cache_behavior" {
  description = "An ordered list of cache behaviors resource for this distribution. List from top to bottom in order of precedence. The topmost cache behavior will have precedence 0."
  type        = any
  default     = []
}