# Project "ombruk" infrastucture

This repository contains terraform config describing the infrastucture needed to run project ombruk. 

## Directory structure

Every top level diretory is it's own "service", except for the special directories modules and base. 
Base contains infrastucture which is used by the other services. Modules houses self contained terraform modules
that can be utilized in other services.

In each service directory there should be at least to sub directories, one for production and one for staging. There may also
be a shared directory that contains infrastucture that is shared between multiple environments. 

## Backend

The terraform state for all these services are stored in an S3 bucket defined in a backend.tf in each project. They all use the same lock table
which means that it's not possible to change two services at the same time.

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
