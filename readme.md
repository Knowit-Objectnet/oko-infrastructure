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


## Created resources
Some of the important resources are described bellow. 

### API Gateway

For the time beeing there we havn't been able to find a good solution to create a few of the resources needed for the API Gateways. 
The reason is that a lot of them are depending on there already beeing a deployment. So for now, the API Gateway is created automatically, 
but you have to manually create the stages and enter the stage variables. The Custom domain name mapping also has to be done manually. 

### Load balancer

Two load balancers per environment is created by the base folder. On public facing ALB and one internal NLB.
The NLB is used to connect the API gateway to the ecs services. 

### ECS Cluster

One ECS cluster per environment is created by the base folder. 

### VPC

One VPC per environmnet is created by the base folder. It usese the cider block 10.0.0.0/16.
There are 9 subnets created. 3 private, 3 public, and 3 db-subnets. Internet connectivity is provided by one NAT gateway per VPC.
