resource "aws_cloudwatch_log_group" "ahmad-ecs-logs-terra" {
  name              = "ahmad-ecs-logs-terra"
  retention_in_days = 7

  tags = {
    "Name" = "ahmad-ecs-logs-terra"
    "owner" = var.owner
  }
}