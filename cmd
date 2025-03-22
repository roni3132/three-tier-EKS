Step 1: IAM Configuration
Create a user eks-admin with AdministratorAccess.
Generate Security Credentials: Access Key and Secret Access Key.

Step 2: EC2 Setup
Launch an Ubuntu instance in your favourite region (eg. region us-east-2).
SSH into the instance from your local machine.


Step 3: Install AWS CLI v2

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin --update
aws configure

Step 4: Install Docker
sudo apt-get update
sudo apt install docker.io
docker ps
sudo usermod -aG docker ubuntu
newgrp docker


Step 5: Install kubectl
curl -o kubectl https://amazon-eks.s3.us-east-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --short --client

Step 6: Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

Step 7: Setup EKS Cluster
eksctl create cluster --name three-tier-cluster --region us-east-2 --node-type t2.medium --nodes-min 1 --nodes-max 3
aws eks update-kubeconfig --region us-east-2 --name three-tier-cluster
kubectl get nodes


git clone https://github.com/roni3132/three-tier-EKS.git

ONLY  FOR TEST PURPOSE 

cd /home/ubuntu/three-tier-EKS/frontend

docker build -t "three-tire" .
docker run -d -p "3000:3000" three-tire:latest


cd /home/ubuntu/three-tier-EKS/backend

docker build -t "three-tire-nodejs" .
docker run -d -p "3500:3500" three-tire-nodejs:latest

ONLY  FOR TEST PURPOSE 

PUSH THIS DOCKER IMAGE IN ECR 

docker tag three-tire:latest 314146303901.dkr.ecr.us-east-2.amazonaws.com/three-tire:latest
docker push 314146303901.dkr.ecr.us-east-2.amazonaws.com/three-tire:latest

docker tag three-tire-nodejs:latest 314146303901.dkr.ecr.us-east-2.amazonaws.com/three-tire-nodejs:latest
docker push 314146303901.dkr.ecr.us-east-2.amazonaws.com/three-tire-nodejs:latest


Step 8: Run Manifests



Step 9: Install AWS Load Balancer
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
eksctl utils associate-iam-oidc-provider --region=us-east-2 --cluster=three-tier-cluster --approve
eksctl create iamserviceaccount --cluster=three-tier-cluster --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::----------------:policy/AWSLoadBalancerControllerIAMPolicy --approve --region=us-east-2


Step 10: Deploy AWS Load Balancer Controller
sudo snap install helm --classic
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=my-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl apply -f full_stack_lb.yaml




-----------------------------------
delete cluster
-----------------------------------
eksctl delete cluster --name three-tier-cluster --region us-east-2
