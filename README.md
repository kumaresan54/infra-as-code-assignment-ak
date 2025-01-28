# Infra as Code - Assignment for IaC Course

## Overview

This repo handles is to create a serverless architecture using AWS services like API Gateway, Lambda, DynamoDB and S3.
This is implemented using Terraform and deployed using GitHub Actions.

![Assignment details and diagram](./images/assignment.png)

## Directory Structure:
Repo contains following directory
- [lambda](./lambda): Contains the lambda code
- [files](./files): Contains the html files
- [terraform](./terraform): Contains the terraform code
- [.github/workflows](./.github/workflows): Contains the github action workflow file

## How to deploy infra resources:
## In Local:
1. Clone the repo
2. Change the directory to terraform
3. Run `terraform init` to initialize the terraform
4. Run `terraform apply` to deploy the resources
5. Once the resources are deployed, you will get the API Gateway URL, DynamoDB ARN and S3 bucket ARN as output
6. To destroy the resources, run `terraform destroy`

## Using GitHub Actions:
1. Clone the repo
2. Switch the directory to terraform/oidc and run `terraform init` to initialize the terraform and `terraform apply` to deploy the resources which is prerequisite for oidc role used in GHA
3. To deploy the resources using GitHub Actions, go to the actions tab and run the workflow(Deploy Infrastructure)
4. Once the resources are deployed, you will get the API Gateway URL, DynamoDB ARN and S3 bucket ARN as output and it get automatically destroyed after the deployment
5. To destroy the resources create for oidc, run `terraform destroy`

## API Details:
- It serves as the first point-of-contact for the end-user, and it helps to redirect requests from the user based on the URL.
    - Requests to “/register” are forwarded to the Lambda which handles user registration
    - Requests to “/” are forwarded to the the Lambda which handles user verification
- Once the deployment is done, the API gateway Url will be printed in the output.


## Note(Implementation details):
* By default, it considers the region as Mumbai(ap-south-1)
* All the resources are created with the prefix(-ak) to avoid conflicting with other resources.
* Cloud watch logs are associated with this resources, so that we can see the logs of the lambda functions.
* We are using the remote state to store the terraform state in S3 bucket(except intial state for github OIDC).
* In GHA workflow,
    * It contains two stages, terraform check which is prerequisite and terraform deploy to deploy the resource.
    * Terraform destroy action will be executed regardless of the previous step output to ensure nothing is left behind.