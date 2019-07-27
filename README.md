# Terraform Kubernetes
This repository contains:
- Terraform manifests and IaC to create the infrastructure to deploy a Kubernetes cluster on AWS
- Automation required to bootstrap the cluster

> Note: I am aware that other projects (Kops to name one) exists to do the same things.
> I just used this as an opportunity to tinker around with Terraform and Bash scripting

## Requirements
- Terraform v0.12.5 (or higher)
  + provider.aws v2.19.0                                                                                                                  
  + provider.local v1.3.0
  + provider.null v2.1.2
  + provider.template v2.1.2

## How-to create the infrastructure with code 
- have your `AWS_PROFILE` environment variable exported, or, alternatively, your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
- Tweak any variables in the `variables.tf` file at your leisure if you want, for instance, to change the number of masters or workers in the cluster.
- Plan the terraform deployment with `terraform plan -out <filename.out>`
- Deploy the infrastructure with `terraform apply <filename.out>`
- The deployment creates a file in the scripts/ folder named `hosts.txt`. Check all your hosts are there.

## How-to bootstrap the Kubernetes cluster
This is done via the `scripts/kubernetes-bootstrap.sh` bash script. 
The script can take a few parameters:
  - `--skip-bundle-upload=True`: Skips the step where the updated scripts are uploaded to all nodes (useful to speed up execution for debugging purposes)
  - `--reset-cluster=True`: Resets all the control plane nodes (including the leader)
  - `--reset-controllers=True`: Resets all the control plane nodes (except the leader)
  - `--reset-workers=True`: Resets all the worker nodes

