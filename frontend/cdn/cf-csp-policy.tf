resource "aws_cloudfront_response_headers_policy" "react_security_headers" {
  name = "security-headers"

  security_headers_config {

    # 🔒 Enforce HTTPS
    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    # 🔒 Prevent MIME sniffing
    content_type_options {
      override = true
    }

    # 🔒 Block iframe embedding (clickjacking protection)
    frame_options {
      frame_option = "DENY"
      override     = true
    }

    # 🔥 FULL WORKING CSP
    content_security_policy {
      override = true

      content_security_policy = <<EOF
default-src 'self';
base-uri 'self';
object-src 'none';
frame-ancestors 'none';

# ✅ Scripts (React needs inline + AWS/CDN)
script-src 
  'self' 
  'unsafe-inline' 
  'unsafe-eval'
  https://*.amazonaws.com 
  https://*.cloudfront.net;

# ✅ Styles (React injects styles dynamically)
style-src 
  'self' 
  'unsafe-inline';

# ✅ Images (S3, CloudFront, base64 images)
img-src 
  'self' 
  data: 
  blob:
  https://*.amazonaws.com 
  https://*.cloudfront.net;

# ✅ Fonts
font-src 
  'self' 
  data:;

# ✅ API Calls (VERY IMPORTANT)
connect-src 
  'self' 
  https://*.amazonaws.com 
  https://*.cloudfront.net;

# ✅ Media (if you ever use video/audio)
media-src 
  'self' 
  https://*.amazonaws.com 
  https://*.cloudfront.net;

# ✅ Allow downloads / workers
worker-src 
  'self' 
  blob:;

# 🔒 Force HTTPS
upgrade-insecure-requests;
EOF
    }

    # 🔒 Referrer control
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
  }
}
