# Example variables for deployment
aws_region         = "us-east-1"
project_name       = "AWS-Messaging-System-Infrastructure"
vpc_cidr           = "10.0.0.0/16"
db_username        = "awsmsguser"
sns_email_endpoint = "athinkosidyoli@gmail.com"
# Note: db_password will be sourced from GitHub secret manager, will need to inject via here if running locally
ecs_image_uri      = "863518437902.dkr.ecr.us-east-1.amazonaws.com/aws-messaging-system-infra-repo:latest"
project_prefix     = "aws-msg-sys"
