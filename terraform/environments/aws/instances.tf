# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = {
    Name        = "${var.app_name}-alb"
    Environment = var.environment
  }
}

# Target Group for API instances
resource "aws_lb_target_group" "api" {
  name     = "${var.app_name}-api-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval          = 30
    matcher           = "200"
    path              = "/health"
    port              = "traffic-port"
    protocol          = "HTTP"
    timeout           = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.app_name}-api-tg"
    Environment = var.environment
  }
}

# Target Group for Load Balancer instance
resource "aws_lb_target_group" "nginx" {
  name     = "${var.app_name}-nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval          = 30
    matcher           = "200"
    path              = "/health"
    port              = "traffic-port"
    protocol          = "HTTP"
    timeout           = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.app_name}-nginx-tg"
    Environment = var.environment
  }
}

# ALB Listener for HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}

# EC2 Instances
resource "aws_instance" "load_balancer" {
  ami                    = "ami-0c02fb55956c7d3165" # Amazon Linux 2023
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/user-data-lb.sh", {
    app_name    = var.app_name
    environment = var.environment
    api_servers = aws_instance.api[*].private_ip
  })

  tags = {
    Name        = "${var.app_name}-load-balancer"
    Environment = var.environment
    Role        = "load-balancer"
  }
}

resource "aws_instance" "api" {
  count                  = var.api_instance_count
  ami                    = "ami-0c02fb55956c7d3165" # Amazon Linux 2023
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index + 1].id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/user-data-api.sh", {
    app_name    = var.app_name
    environment = var.environment
    node_number = count.index + 1
  })

  tags = {
    Name        = "${var.app_name}-api-${count.index + 1}"
    Environment = var.environment
    Role        = "api-server"
  }
}

# Attach API instances to target group
resource "aws_lb_target_group_attachment" "api" {
  count            = var.api_instance_count
  target_group_arn = aws_lb_target_group.api.arn
  target_id        = aws_instance.api[count.index].id
  port             = 8000
}

# Attach Load Balancer instance to target group
resource "aws_lb_target_group_attachment" "nginx" {
  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = aws_instance.load_balancer.id
  port             = 80
}
