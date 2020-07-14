# Project "ombruk" infrastucture

This repository contains terraform config describing the infrastucture needed to run project ombruk. 

## Directory structure

All the directories in root level contains a seperate service or application. The exceptions are modules which contain terraform modules
and base which contain infrastructure that is shared among several projects. 

In each service directory there should be at least two subdirectories named staging and production, one for each environment.
There may also be a subdirectory called shared which contains infrastructure that is shared between the environments.

## Backend

The terraform state for all these services are stored in an S3 bucket defined in a backend.tf in each project. They all use the same lock table
which means that it's not possible to change two services at the same time.

## SNS subscriptions
The SNS subscriptions depond on both the service's own queue and other services' topics. Because of this SNS subscriptions have their own sub directory that can
be applied when their dependencies have already been configured. 

## Created resources
Some of the important resources are described bellow. 

### API Gateway

One API gateway is created for each environment. All the services register their own resources and integrations.

### Load balancer

Two load balancers per environment is created by the base folder. On public facing ALB and one internal NLB.
The NLB is used to connect the API gateway to the ecs services. 

### ECS Cluster

One ECS cluster per environment is created by the base folder. 

### VPC

One VPC per environmnet is created by the base folder. It usese the cider block 10.0.0.0/16.
There are 9 subnets created. 3 private, 3 public, and 3 db-subnets. Internet connectivity is provided by one NAT gateway per VPC.

### SNS

Every service may have their own SNS topic to publish their events.

### SQS

Every service may have an SQS queue that subscribes to whichever topics it wants. 