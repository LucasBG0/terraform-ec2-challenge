locals {
  vars = {
    bucket_url = "https://${var.bucket.name}.s3.amazonaws.com/${var.bucket.object}"
  }
}

resource "aws_instance" "web_server" {
  instance_type               = var.instance_type
  ami                         = var.ami_id
  key_name                    = var.key_name
  vpc_security_group_ids      = var.sg_ids
  user_data                   = base64encode(templatefile(var.user_data, local.vars))
  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.cloud_watch_agent_profile.name
  tags = {
    Name = "${var.instance_name}"
  }
}

resource "aws_iam_role" "cloud_watch_agent_server_role" {
  name        = "CloudWatchAgentServerRole"
  description = "Role created to allow metrics to CloudWatch"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloud_watch_agent_server" {
  role       = aws_iam_role.cloud_watch_agent_server_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "cloud_watch_agent_profile" {
  name = "cloud_watch_agent_profile"
  role = aws_iam_role.cloud_watch_agent_server_role.name
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name                = "CpuAlarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []

  dimensions = {
    InstanceId = "${aws_instance.web_server.id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  alarm_name                = "MemoryAlarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "mem_used_percent"
  namespace                 = "CWAgent"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 mem utilization"
  insufficient_data_actions = []

  dimensions = {
    host = trimsuffix("${aws_instance.web_server.private_dns}", ".ec2.internal")
  }
}


resource "aws_cloudwatch_metric_alarm" "disk" {
  alarm_name                = "DiskAlarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "disk_used_percent"
  namespace                 = "CWAgent"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "75"
  alarm_description         = "This metric monitors ec2 disk utilization"
  insufficient_data_actions = []

  dimensions = {
    host   = trimsuffix("${aws_instance.web_server.private_dns}", ".ec2.internal")
    path   = "/"
    device = "xvda1"

    fstype = "ext4"

  }
}
