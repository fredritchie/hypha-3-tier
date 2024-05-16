output "alb_dns_name" {
  value = aws_lb.webapp-ALB.dns_name
}
output "s3_website_dns_name" {
  value = aws_s3_bucket_website_configuration.static_website_bucket.website_endpoint
}
output "s3_bucket_name" {
  value = aws_s3_bucket.static_website_bucket.bucket
}