
output "pmo-maven-ip" {
  value = aws_instance.pmo-maven.public_ip
}

#output "pmo-jenkins-ip" {
#value = aws_instance.pmo-jenkins.public_ip
#}

output "pmo-prod-ip" {
  value = aws_instance.pmo-prod.public_ip
}
