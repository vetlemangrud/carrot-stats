output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.carrot_deployment.invoke_url}/carrots"
}