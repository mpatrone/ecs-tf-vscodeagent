## Prompt 1
Create the directory tree for a Terraform project targeting the AWS cloud. The project must include
environments for dev and prod and three modules: one for networking, another for middleware and a third one for app code. Name these modules "networking", "middleware" and "app" respectively

## Prompt 2
Let's refine the networking module.
First off I want to operate only on the us-east-1 region.
I want a VPC with 4 subnets, two public and two private. The cide must be 10.0.0.0/16.
I want an internet gateway attached to that vpc. And I want one NAT gateway created on a public subnet.

## Prompt 3
Let's refine the middleware module.
I want to create an ALB with two listeners: one for http and another for https.
The https listener must attach an existing ACM certificate for "patrone.click"
Both listeners must point to a target group that will be used later in the app module for registering
ECS tasks. Create a security group for the ALB.

## Prompt 4
Let's refine the app module.
I wan to create two ECS tasks (tf-task1, tf-task2) each with its task definition (tf-td1, tf-td2) and
each with its own service (tf-svc1, tf-svc2). 
The first task tf-task1 must run on a public subnet and must integrate with the target group created in the middleware module. The other task tf-task2 must run on a private subnet.
Both tasks listen on port 80.
Both tasks must use the ubuntu/nginx image. Both tasks require 4Gb of memory and 2 vcpus.
Both services must use the ECS service connect namespace tf-ns as client/server with dnsname identical to the service name and using port 80.
Both services must log in CloudWatch in streams identical to the service names.
Both services must be accessible via ECS exec. Create the necessary changes in the corresponding task definitions.
Create IAM roles for execution ecsTaskExecutionRoleTF and task role ecsTaskRoleTF. Permission for pulling images from the outside repository and for logging in CloudWatch must be included in the roles.
Create separate security groups for the public task (tf-sg-public) and for the private task (tf-sg-private) allowing access on port 80 in both cases.

## Prompt 5 - problem correction
There is a problem with the input variables of the networking module. The environment module is sending azs, private_subnets, public_subnets and tags but the networking module is not using those. Make the necessary changes for:
1. azs must be used in the networking module.
2. public_subnets instead of public_subnet_cidrs
3. private_subnets instead of private_subnet_cidrs
4. Drop the usage of tags input from the environment modules

## Prompt 6 - problem corrections
Please correct the following problem in the ECS task definitions. The portMappings block in the container_definitions of both tasks, must include the name element whose contents must be "http"
Please correct the following problem: in the middleware module, the health_check block of the ALB, the path must be "/" instead of "/health"

## Prompt 7
I have one additional requirement.
On the middleware module, I want you to add a record to the Route53 public hosted zone for "patrone.click". The entry must be an alias to the ALB created in this module, and must have the name "terraform"

## Note
Add to add an additional policy to the ecsTaskRoleTF in order to allow remote ECS exec.
