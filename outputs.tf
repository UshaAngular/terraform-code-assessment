output "write_lambda_function_name" {
  value = aws_lambda_function.write_inbound.function_name
}

output "read_lambda_function_name" {
  value = aws_lambda_function.read_outbound.function_name
}