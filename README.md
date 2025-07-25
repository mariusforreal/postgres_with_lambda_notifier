# Order Notifier Terraform Deployment

## Overview

This project automates the deployment of an AWS infrastructure for an **Order Notification System** using Terraform. The system includes:

- **Amazon RDS PostgreSQL** database for storing orders and related data.
- **AWS Secrets Manager** for securely storing and managing the database credentials.
- **Amazon SNS (Simple Notification Service)** topic to send email notifications about new orders.
- **AWS Lambda function** that:
  - Connects securely to the RDS database.
  - Queries for new, unnotified orders.
  - Sends notification messages to the SNS topic.
  - Marks orders as notified in the database.
- **EventBridge (CloudWatch Events) rule** to trigger the Lambda function every 5 minutes.

---

## Architecture

1. **RDS PostgreSQL** stores order data and related information. A sample `order_events` table should exist in this DB to track new orders.
2. **Secrets Manager** securely stores the RDS master username and password.
3. **SNS Topic** acts as the messaging hub to publish order notifications.
4. **Lambda Function** runs every 5 minutes to:
   - Retrieve DB credentials from Secrets Manager.
   - Connect to the PostgreSQL instance.
   - Query for new orders where `notified = false`.
   - Publish order notifications to the SNS topic.
   - Update the orders as notified in the database.
5. **EventBridge Rule** schedules the Lambda invocation on a fixed interval.

---

## Prerequisites

- Terraform (v1.3 or newer) installed on your machine.
- AWS CLI configured with credentials that have sufficient permissions to create all resources.
- Python 3.x installed (to prepare the Lambda package).
- Git installed (to clone this repo).

---

## Getting Started

1. Clone the repository

```bash
git clone https://github.com/mariusforreal/postgres_with_lambda_notifier.git
cd postgres_with_lambda_notifier


2. Prepare the Lambda Deployment Package
The Lambda function code should implement the logic discussed previously (querying the DB, sending SNS notifications).
Place your Python Lambda code in a file called lambda_function.py.
Create a deployment package ZIP including dependencies if necessary.
For example, if you have dependencies:

mkdir package
pip install psycopg2-binary -t package/
cp lambda_function.py package/
cd package
zip -r ../lambda_function.zip .
cd ..
If no external dependencies besides boto3 (which is included by AWS Lambda environment), simply:

zip lambda_function.zip lambda_function.py
Make sure lambda_function.zip is in the Terraform folder.

3. Review and Customize Variables
Open variables.tf and adjust:

aws_region (default: us-east-1)
project_name (used to prefix resource names)
db_name (database name)
db_username (Postgres admin username)

4. Initialize and Apply Terraform
Run the following commands:

terraform init
terraform plan -out=tfplan
terraform apply tfplan
Terraform will:

Create a new VPC, subnets, and internet gateway.
Create a security group allowing Lambda to connect to RDS.
Launch an RDS PostgreSQL instance.
Store the DB credentials in AWS Secrets Manager.
Create an SNS topic.
Create an IAM Role and Policy with permissions for Lambda.
Deploy the Lambda function with environment variables set.
Schedule Lambda to run every 5 minutes.
5. Update the Database Schema
Once your RDS instance is available:

Connect to it using your favorite SQL client (psql, pgAdmin, etc.) with the credentials output by Terraform:
psql -h <rds_endpoint> -U <db_username> -d <db_name>

Create the order_events table schema (adjust as necessary):

```CREATE TABLE order_events (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    notified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
); ```

Insert sample order data for testing:
INSERT INTO order_events (order_id, user_id, total_amount, notified) VALUES
(1, 101, 50.00, false),
(2, 102, 75.50, false);

6. Subscribe to the SNS Topic
Go to the AWS SNS Console.
Find the SNS Topic created by Terraform (named like ${project_name}-order-notifications).
Create a subscription with your email address using the Email protocol.
Confirm the subscription from your email.

7. Testing
Wait up to 5 minutes for the Lambda to trigger.
The Lambda will query the database, find unnotified orders, send notification emails via SNS, and mark orders as notified.
Check the Lambda CloudWatch logs for details.
Verify you receive emails for the new orders.

8. Cleaning Up
To destroy all resources created by Terraform:

terraform destroy
This will delete the RDS instance, Lambda, SNS topic, Secrets Manager secret, and networking resources.

Notes and Best Practices

Security: This example uses a publicly accessible RDS instance for simplicity. For production, place your RDS in private subnets with no public access.
Secrets Management: Database credentials are stored securely in Secrets Manager and retrieved by Lambda at runtime.
Lambda VPC Access: Lambda is deployed inside the same VPC and security group to access RDS securely.
Timeouts and Retries: Adjust Lambda timeout and error handling as per your needs.
Schema & Logic: Customize the database schema and Lambda logic to fit your application.