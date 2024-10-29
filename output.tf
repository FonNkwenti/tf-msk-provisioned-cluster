output "kafka_client_cmd" { 
    description = "The AWS cli command to connect to the ec2 kafka client via EC2 instance connect endpoint"
    value = "aws ec2-instance-connect ssh --instance-id ${module.kafka_client_instance.id} --os-user ec2-user --connection-type eice --region ${var.main_region}"
}


