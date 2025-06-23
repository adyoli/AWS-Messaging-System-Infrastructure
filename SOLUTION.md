# Solution Overview

This document outlines the architecture, trade-offs, security considerations, monitoring, and cost-optimization strategies for the simple messaging system on AWS.

## Architecture

- **VPC**: Public and private subnets across multiple AZs with NAT Gateway for outbound access.
- **ECS Fargate**: Runs a custom Flask application behind an ALB.
- **RDS PostgreSQL**: Stores persistent data and sessions in private subnets.
- **DynamoDB**: Metadata storage with pay-per-request billing.
- **SQS & SNS**: Asynchronous messaging; SNS delivers alerts via email subscription.
- **CloudWatch**: Logs aggregated from ECS and metrics used to trigger alarms.

## Security & IAM

- **Least-Privilege IAM Roles**:
  - ECS Task Role: Only allowed to read/write the specific DynamoDB table and RDS credentials from Secrets Manager.
  - CI/CD Role: Limited to `ecr:*`, `ecs:*`, and `terraform:*` actions.
- **Security Groups**:
  - ALB SG: Allows inbound HTTP/S from 0.0.0.0/0.
  - ECS SG: Allows inbound from ALB SG; outbound to RDS, DynamoDB, SQS.
  - RDS SG: Accepts inbound only from ECS SG.

## Monitoring & Alerting

- **CloudWatch Log Groups**:
  - `/ecs/flask-app-service`
  - `/terraform/deploy`
- **Alarms**:
  1. **RDS CPU Utilization > 80%** for 5 minutes → Alarm to SNS topic.
  2. **SQS ApproximateNumberOfMessagesVisible > 100** for 10 minutes → Alarm to SNS topic.

## Trade-offs

- **ECS Fargate vs. EC2**:
  - Fargate simplifies management but has higher per-vCPU memory pricing.
  - EC2 would reduce compute costs at the expense of cluster management overhead.
- **DynamoDB On-Demand vs. Provisioned**:
  - On-Demand scales automatically—ideal for unpredictable load—but more expensive than reserved capacity for steady traffic.

## Cost Optimization Strategies

1. **Spot Fargate**:
   - Savings: ~70%; Trade-off: potential task interruptions, require checkpointing or autoscaling strategies.

2. **RDS Reserved Instances**:
   - Savings: up to 50% off On-Demand pricing; Trade-off: 1–3 year upfront commitment.

3. **DynamoDB Reserved Capacity**:
   - For predictable workloads, purchase reserved capacity to reduce read/write costs by ~60%.

## Further Improvements

- **Autoscaling**: Implement ECS Service Autoscaling based on CPU and memory metrics.
- **Secrets Management**: Store DB credentials in AWS Secrets Manager or Parameter Store.
