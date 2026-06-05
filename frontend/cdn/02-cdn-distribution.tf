# CLOUDFRONT OAC
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-oac"
  description                       = "OAC for private S3 access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#---------------------------------------------------------
# Cache Policies
#---------------------------------------------------------
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

# CLOUDFRONT DISTRIBUTION
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  # S3 Origin (React app)
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # API Origin (API GATEWAY)
  origin {
    domain_name = replace(aws_apigatewayv2_api.api.api_endpoint, "https://", "")
    origin_id   = "api-origin"

    # ✅ OPTIONAL (if using stage like /dev) # origin_path = "/dev"
    # origin_path = "/dev"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    # 🔥 SECRET HEADER (Handle in WAF, Backend and Lambda)
    custom_header {
      name  = "X-From-CloudFront"
      value = "my-super-secret-123"
    }
  }

  # Default → S3
  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true
    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id
    # response_headers_policy_id = aws_cloudfront_response_headers_policy.react_security_headers.id
  }

  # /api → API Gateway
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "api-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET","HEAD","OPTIONS","POST","PUT","DELETE", "PATCH"]
    cached_methods  = ["GET","HEAD"]
    
    compress = true

    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.all_viewer.id
    # response_headers_policy_id = aws_cloudfront_response_headers_policy.react_security_headers.id
  }

  # React SPA custom error page 403
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  # React SPA custom error page 404
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
    
  price_class = var.env == "dev" ? "PriceClass_100" : "PriceClass_200"    # PriceClass_100 (US,EU)

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # 🔥 IMPORTANT (so destroy works)
  retain_on_delete = false
  
#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     acm_certificate_arn = aws_acm_certificate.cert.arn
#     ssl_support_method  = "sni-only"
#   }

#   CDN URL https://roboshop-dev.daws88s.online
#   aliases = [var.domain_name]

  tags = {
    Name = "${var.project}-${var.env}-cdn"
  }
}




