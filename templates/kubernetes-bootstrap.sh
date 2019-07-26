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
%{ for instance in jsondecode(masters) ~}
scp -i ~/.ssh/id_rsa /tmp/kubeadm-config.yml ec2-user@${instance.public_dns}:.
%{ endfor ~}
%{ for instance in jsondecode(workers) ~}
scp -i ~/.ssh/id_rsa /tmp/kubeadm-config.yml ec2-user@${instance.public_dns}:.
%{ endfor ~}

# Reset controllers if flag set
if [[ $* == *--reset-controllers* ]]; then
COMMAND="sudo kubeadm reset --force && sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X"
%{ for instance in jsondecode(masters) ~}
separator
echo "Reset cluster (controller node ${instance.public_dns})"
separator
ssh -i ~/.ssh/id_rsa ec2-user@${instance.public_dns} $COMMAND
%{ endfor ~}
rm cluster.state
fi

# Reset workers if flag set
if [[ $* == *--reset-workers* ]]; then
COMMAND="sudo kubeadm reset --force && sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X"
%{ for instance in jsondecode(workers) ~}
separator
echo "Reset cluster (worker node ${instance.public_dns})"
separator
ssh -i ~/.ssh/id_rsa ec2-user@${instance.public_dns} $COMMAND
%{ endfor ~}
fi

# Initialise cluster
if ! grep -q "\-\-control-plane" cluster.state; then
separator
echo "Initialise cluster"
separator
COMMAND="sudo kubeadm init --config=/home/ec2-user/kubeadm-config.yml --upload-certs"
ssh -i ~/.ssh/id_rsa ec2-user@${jsondecode(masters)[0].public_dns} $COMMAND > cluster.state
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
COMMAND="sudo "
COMMAND+=$(grep -E "\s+kubeadm join\s" cluster.state -A2) 
COMMAND=$(echo $COMMAND | sed 's/\\//g' | tr '\n' ' ')
%{ for instance in slice(jsondecode(masters),1,length(jsondecode(masters))) ~}
separator
echo "Join controller node ${instance.public_dns}"
separator
ssh -i ~/.ssh/id_rsa ec2-user@${instance.public_dns} $COMMAND
%{ endfor ~}

# Join workers
separator
echo "Join workers"
separator
COMMAND="sudo "
COMMAND+=$(grep -E "^kubeadm\s" cluster.state -A2) 
COMMAND=$(echo $COMMAND | sed 's/\\//g' | tr '\n' ' ')
%{ for instance in jsondecode(workers) ~}
separator
echo "Join worker node ${instance.public_dns}"
separator
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

# Configure local user for kubectl
COMMAND="sudo cat /etc/kubernetes/admin.conf"
ssh -i ~/.ssh/id_rsa ec2-user@${jsondecode(masters)[0].public_dns} $COMMAND > $HOME/.kube/config