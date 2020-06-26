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