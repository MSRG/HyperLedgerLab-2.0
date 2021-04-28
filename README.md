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
