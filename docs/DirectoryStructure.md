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
    - [`config-template/`](../fabric/config-template): helm chart used to generate config files taking as input the configuration in [`network-configuration.yaml`](../fabric/network-configuration.yaml)
    - [`argo/`](../fabric/argo) contains a Kubernetes workload resource to install argo controller on Kubernetes.

4.  **[`caliper/`](../caliper)**: This folder contains all necessary configuration files to run the benchmarking tool: Hyperledger Caliper.

    This folder contains the following subdirectories:

    - [`benchmarks/`](../caliper/benchmarks): Contains folders for different chaincodes. Each chaincode folder contains the rounds definition in config.yaml file and the different workloads.
    - [`config-template/`](../caliper/config-template): helm chart used to generate config files for caliper as well as the deployment definitions for the Caliper Manager and Caliper Worker(s) taking as input the configuration in [`network-configuration.yaml`](../fabric/network-configuration.yaml).
    - [`mosquitto/`](../caliper/mosquitto): contains the Kubernetes workload resources to set up mosquitto as the MQTT broker service.

5.  **[`docs/`](../docs)**: It contains the documentation for this project. These documentation files are linked to README.md in the main project folder.

6.  **[`Kubespray/`](../kubespray)**: An external module [kubespray](https://github.com/kubernetes-sigs/kubespray) added as a git submodule. Kubespray is used primarily to install a Kubernetes cluster on the Openstack infrastructure.
