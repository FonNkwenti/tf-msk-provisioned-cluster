################################################################################
# Cluster
################################################################################
resource "aws_kms_key" "kafka_kms_key" {
  description = "Key for Apache Kafka"
}

resource "aws_cloudwatch_log_group" "kafka_log_group" {
  name = "kafka_broker_logs"
}

resource "aws_msk_configuration" "kafka_config" {
  kafka_versions    = ["3.4.0"] 
  name              = "${local.name}-config"
  server_properties = <<EOF
auto.create.topics.enable = true
delete.topic.enable = true
EOF
}

resource "aws_msk_cluster" "kafka" {
  cluster_name           = local.name
  kafka_version          = "3.4.0"
  number_of_broker_nodes = length(data.aws_availability_zones.main.names)
  broker_node_group_info {
    instance_type = "kafka.t3.small" 
    # instance_type = "kafka.m5.large" 
    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }
    client_subnets = module.msk_vpc.private_subnets
    security_groups = [aws_security_group.kafka.id]
  }
  encryption_info {
    encryption_in_transit {
      client_broker = "PLAINTEXT"
    }
    encryption_at_rest_kms_key_arn = aws_kms_key.kafka_kms_key.arn
  }
  configuration_info {
    arn      = aws_msk_configuration.kafka_config.arn
    revision = aws_msk_configuration.kafka_config.latest_revision
  }
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.kafka_log_group.name
      }
    }
  }
}

resource "aws_security_group" "kafka" {
  name   = "${local.name}-kafka"
  vpc_id = module.msk_vpc.vpc_id
  ingress {
    from_port   = 0
    to_port     = 9092
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = var.private_cidr_blocks
  }
  ingress {
    from_port   = 0
    to_port     = 9092
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = var.cidr_blocks_bastion_host
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# resource "tls_private_key" "private_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "private_key" {
#   key_name   = var.global_prefix
#   public_key = tls_private_key.private_key.public_key_openssh
# }

# resource "local_file" "private_key" {
#   content  = tls_private_key.private_key.private_key_pem
#   filename = "cert.pem"
# }

# resource "null_resource" "private_key_permissions" {
#   depends_on = [local_file.private_key]
#   provisioner "local-exec" {
#     command     = "chmod 600 cert.pem"
#     interpreter = ["bash", "-c"]
#     on_failure  = continue
#   }
# }
