# HyperledgerLab II

Hyperledger Testbed on Kubernetes Cluster: Automated Deployment of a Distributed Enterprise Blockchain Network for Analysis and Testing

## Summary

This repository contains scripts we are developing to deploy a Hyperledger Testbed on a Kubernetes cluster, itself running on cloud resources. For the latter, we assume, resources provisioned via an OpenStack environment.

**CONTRIBUTOR**: Mohamed Karim Abbes (karim.abbes@outlook.com)

## Quick Setup

For a quick setup of this software, please see: [HowToUse](docs/HowToUse.md).

## Supported Versions

- Kubernetes v1.21.1
- Hyperledger Fabric: v1.2.1 and v1.4.0
- Develpment was done on Ubuntu 20.04

## Installation Process

This is a 4 steps process as follows:

1.
2.
3.
4.

## Project Structure

A breakdown of the code structure: [DirectoryStructure](docs/DirectoryStructure.md)

## References

- Infrastructure provisioning with Terraform was inpired by a tutorial in the official Kubespray repository: [Kubernetes on OpenStack with Terraform](https://github.com/kubernetes-sigs/kubespray/tree/master/contrib/terraform/openstack)
- Running and operating the Hyperledger Fabric network in Kubernetes was highly inspired by the open source project [PIVT by Hakan Eryargi](https://github.com/hyfen-nl/PIVT)
