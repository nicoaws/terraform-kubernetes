#!/bin/bash
function separator() 
{
  echo "========================================================================="
}

cat > /tmp/kubeadm-config.yml <<EOT 
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: "${NLB_DNS_NAME}:${NLB_PORT}"
EOT
scp -i ~/.ssh/id_rsa /tmp/kubeadm-config.yml ec2-user@${jsondecode(masters)[0].public_dns}:.

# Reset if flag set
if [[ $* == *--reset* ]]; then
COMMAND="sudo kubeadm reset --force && sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X"
  %{ for instance in jsondecode(masters) ~}
  separator
  echo "Reset cluster (node ${instance.public_dns})"
  separator
  ssh -i ~/.ssh/id_rsa ec2-user@${instance.public_dns} $COMMAND
  %{ endfor ~}
rm command.out
fi

# Initialise cluster
if ! grep -q "\-\-control-plane" command.out; then
  separator
  echo "Initialise cluster"
  separator
  COMMAND="sudo kubeadm init --config=/home/ec2-user/kubeadm-config.yml --upload-certs"
  echo $COMMAND
  ssh -i ~/.ssh/id_rsa ec2-user@${jsondecode(masters)[0].public_dns} $COMMAND > command.out
fi

separator
echo "Configure user for kubectl on master node"
separator
COMMAND="
mkdir -p \$HOME/.kube &&
sudo cp /etc/kubernetes/admin.conf \$HOME/.kube/config &&
sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config"
ssh -i ~/.ssh/id_rsa ec2-user@${jsondecode(masters)[0].public_dns} $COMMAND

separator
echo "Install Calico"
separator
COMMAND="kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml"
ssh -i ~/.ssh/id_rsa ec2-user@${jsondecode(masters)[0].public_dns} $COMMAND

# Join other controllers
separator
echo "Join controllers"
separator
COMMAND="sudo kubeadm reset --force && sudo"
COMMAND+=$(grep "\-\-control-plane" command.out -B2) 
COMMAND=$(echo $COMMAND | sed 's/\\//g' | tr '\n' ' ')
%{ for instance in slice(jsondecode(masters),1,length(jsondecode(masters))) ~}
ssh -i ~/.ssh/id_rsa ec2-user@${instance.public_dns} $COMMAND
%{ endfor ~}

# Configure user for kubectl
separator
echo "Configure user for kubectl"
separator
COMMAND="
mkdir -p \$HOME/.kube &&
sudo cp /etc/kubernetes/admin.conf \$HOME/.kube/config &&
sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config"
%{ for instance in  slice(jsondecode(masters),1,length(jsondecode(masters))) ~}
ssh -i ~/.ssh/id_rsa ec2-user@${instance.public_dns} $COMMAND
%{ endfor ~}

# Get nodes
COMMAND="kubectl get nodes"
ssh -i ~/.ssh/id_rsa ec2-user@${jsondecode(masters)[0].public_dns} $COMMAND

