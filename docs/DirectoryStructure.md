# **Directory Structure**

The project consists of 6 main folders:

1.  **[`scripts/`](../scripts)**: It contains different scripts with goal-oriented titles, for one-click execution of the different steps of the framework.

2.  **[`terraform/`](../terraform)**: This folder contains mainly configuration yaml and tf files used to provision infrastructure on Openstack cluster and later to install a Kubernetes cluster on the just provisioned infrastructure.

3.  **[`fabric/`](../fabric)**: This folder contains all necessary yaml configuration files plus scripts used during the installation of the network.

    This folder contains the following subdirectories:

    - [`hlf-kube/`](../fabric/hlf-kube) : the main helm chart to configure and launch a Hyperledger Fabric network on the running Kubernetes cluster.
    - [`chaincode/`](../fabric/chaincode) : contains different defined chaincodes
    - [`channel-flow/`](../fabric/channel-flow): helm chart to create channels, join peers to channels and update channels for anchor peers.
    - [`chaincode-flow/`](../fabric/chaincode-flow): helm chart to install, instantiate, upgrade and invoke chaincodes
    - Network configuration subfolders like [`raft-tls/`](../fabric/raft-tls): contains configuration for a specific network configuration to override the by default configuration values in the main helm chart: hlf-kube.

4.  **[`caliper/`](../caliper)**: This folder contains all necessary configuration files to run the benchmarking tool: Hyperledger Caliper.

5.  **[`docs/`](../docs)**: It contains the documentation for this project. These documentation files are linked to README.md in the main project folder.

6.  **[`Kubespray/`](../kubespray)**: An external module [kubespray](https://github.com/kubernetes-sigs/kubespray) added as a git submodule. Kubespray is used primarily to install a Kubernetes cluster on Openstack infrastructure.
