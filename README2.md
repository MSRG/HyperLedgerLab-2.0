# HyperledgerLab2

Documentation first draft

- Create CLI instance
- copy private and public keys to the CLI

  `private: scp -i ~/.ssh/key ~/.ssh/key ubuntu@<IP>:/home/ubuntu/.ssh/id_rsa`
  `public: scp -i ~/.ssh/key ~/.ssh/key.pub ubuntu@<IP>:/home/ubuntu/.ssh/id_rsa.pub`

Terraform part:

- terraform used version 0.15.0
- edit cluster.tfvars
- create clouds.yaml following sample_cloud.yaml. (if you choose to change the cloud's name mycloud then change also the cloud name in OpenStack Provider configuration located in terraform/versions.tf)
- In terraform do
  ` terraform init` then `terraform apply -var-file=./cluster.tfvars`
- Ensure your local ssh-agent is running and your ssh key has been added.
  `eval $(ssh-agent -s)`
  `ssh-add ~/.ssh/id_rsa`
- Check if all instances are reachable
  `ansible -i hosts -m ping all`
- Setup k8s cluster (in terraform folder)
  `ansible-playbook --become -i hosts ../kubespray/cluster.yml`
- fill hosts.ini with the actual values and configure kubectl (in terraform folder)
  `ansible-playbook -i hosts ../playbook.yaml`

Trouble shooting:

fatal: [hyperledgerlab-k8s-node-nf-1]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: ssh: connect to host <ip-address> port 22: Connection refused", "unreachable": true}

Try run ./k8s_setup.sh again. The instances take some time to boot. I consider 60s as sleep time but it could take longer.
