##################    ECS Resources    ##########################
resource "aws_ecs_cluster" "ahmad-ecs-cluster-terra" {
  name = "ahmad-ecs-cluster-terra"
  tags = {
    "Name" = "ahmad-ecs-cluster-terra"
    "owner" = "ahmad"
  }
}

resource "aws_ecs_task_definition" "ahmad-taskdef-terra" {
  family = "ahmad-taskdef-terra"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  
  execution_role_arn = "arn:aws:iam::504649076991:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
        name = "nginx-terra"
        image = "504649076991.dkr.ecr.us-east-2.amazonaws.com/ahmad-repo-terra:nginxhello"
        cpu = 256
        memory = 512
        essential = true
        portMappings = [
            {
                containerPort = 80
                hostPort = 80
            }
        ]
        logConfiguration = {
          logDriver = "awslogs"
            options = {
              awslogs-group         = "ahmad-ecs-logs-terra"
              awslogs-region        = var.aws_region
              awslogs-stream-prefix = "ecs"
            }
          }
    }
  ])

  depends_on = [ aws_ecr_repository.ahmad-repo-terra, null_resource.ecr-docker-push-ahmad ]
  tags = {
    "Name" = "ahmad-taskdef-terra"
    "owner" = "ahmad"
  }
}

resource "aws_ecs_service" "ahmad-service-terra" {
  name = "ahmad-service-terra"
  launch_type = "FARGATE"
  cluster = aws_ecs_cluster.ahmad-ecs-cluster-terra.id
  task_definition = aws_ecs_task_definition.ahmad-taskdef-terra.arn
  desired_count = 2
  
  network_configuration {
    subnets = [var.subnet1, var.subnet2]
    security_groups = [var.sg-group]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ahmad-lb-targroup-terra.arn
    container_name = "nginx-terra"
    container_port = 80
  }

  depends_on = [ aws_lb_listener.ahmad-lb-listener-terra ]
  tags = {
    "Name" = "ahmad-service-terra"
    "owner" = "ahmad"
  }
}

resource "aws_ecr_repository" "ahmad-repo-terra" {
  name = "ahmad-repo-terra"
  image_tag_mutability = "MUTABLE"
  force_delete = true
}

resource "null_resource" "ecr-docker-push-ahmad" {
  depends_on = [ aws_ecr_repository.ahmad-repo-terra ]
  provisioner "local-exec" {
    command = <<EOF
      docker pull nginxdemos/hello:latest
      aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 504649076991.dkr.ecr.us-east-2.amazonaws.com
      docker tag nginxdemos/hello:latest 504649076991.dkr.ecr.us-east-2.amazonaws.com/ahmad-repo-terra:nginxhello
      docker push 504649076991.dkr.ecr.us-east-2.amazonaws.com/ahmad-repo-terra:nginxhello
    EOF
  }
}


############ ALB Logic  ###############
resource "aws_lb" "ahmad-lb-terra" {
  name = "ahmad-lb-terra"
  load_balancer_type = "application"
  security_groups = [ var.sg-group ]
  subnets = [ var.subnet1, var.subnet2 ]

  tags = {
    "Name" = "ahmad-lb-terra"
    "owner" = "ahmad"
  }
}

resource "aws_lb_target_group" "ahmad-lb-targroup-terra" {
  name = "ahmad-lb-targroup-terra"
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = var.vpc-id
}

resource "aws_lb_listener" "ahmad-lb-listener-terra" {
  load_balancer_arn = aws_lb.ahmad-lb-terra.arn
  port = 80
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ahmad-lb-targroup-terra.arn
  }
}












