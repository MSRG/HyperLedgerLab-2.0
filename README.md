# HyperledgerLab2

Documentation first draft

- Create CLI instance
- copy private and public keys to the CLI

  `private: scp -i ~/.ssh/key ~/.ssh/key ubuntu@<IP>:/home/ubuntu/.ssh/id_rsa`
  `public: scp -i ~/.ssh/key ~/.ssh/key.pub ubuntu@<IP>:/home/ubuntu/.ssh/id_rsa.pub`

Terraform part:

- terraform used version 0.15.0
- create clouds.yaml following sample_cloud.yaml.
- For now, you should do export OS_CLOUD=mycloud (mycloud is the name defined in clouds.yaml)
- In terraform do
  ` terraform init` then `terraform apply -var-file=./cluster.tfvars`
