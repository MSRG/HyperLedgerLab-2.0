# **HyperledgerLab II**

Hyperledger Testbed on Kubernetes Cluster: Automated Deployment of a Distributed Enterprise Blockchain Network for Analysis and Testing

## Summary

This repository contains scripts and helm charts we are developing to deploy a Hyperledger Testbed on a Kubernetes cluster, itself running on cloud resources. For the latter, we assume, resources provisioned via an OpenStack environment.
A benchmarking tool: Hyperledger Caliper is configured to evaluate and collect metrics of the deployed network.

**CONTRIBUTOR**: Mohamed Karim Abbes (karim.abbes@outlook.com)

## Quick Setup

For a quick setup of this software, please see: [HowToUse](docs/HowToUse.md).

## Supported Versions

- Kubernetes v1.21.1
- Docker 20.10.7
- Hyperledger Fabric: v2.x
- Hyerledger Caliper: v0.4.2
- Operating system: Software has been developed on Ubuntu 20.04 LTS

## Project Structure

A breakdown of the code structure: [DirectoryStructure](docs/DirectoryStructure.md)

## Comparison between HyperledgerLab I and II

A comparative table of the main features of HyperledgerLab I and II: [Version 1 and 2 Comparison](./docs/ComparativeTable.md).

## References

- Infrastructure provisioning with Terraform was inpired by a tutorial in the official Kubespray repository: [Kubernetes on OpenStack with Terraform](https://github.com/kubernetes-sigs/kubespray/tree/master/contrib/terraform/openstack)
- Running and operating the Hyperledger Fabric network in Kubernetes was highly inspired by the open source project [PIVT by Hakan Eryargi](https://github.com/hyfen-nl/PIVT)
