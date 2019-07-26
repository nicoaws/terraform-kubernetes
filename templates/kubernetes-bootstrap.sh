#!/bin/bash

MASTERS=( %{ for instance in jsondecode(masters) ~} ${instance.public_dns} %{ endfor ~})
WORKERS=( %{ for instance in jsondecode(workers) ~} ${instance.public_dns} %{ endfor ~})
PRIVATE_KEY=~/.ssh/id_rsa
SSH_USER=ec2-user
LOGFILE=kubernetes-bootstrap.log
echo "" > $LOGFILE

function separator() 
{
  echo "#=========================================================================#"
  echo "# $1"
  echo "#=========================================================================#"
}

function sshcommand()
{ 
  command=$1
  host=$2
  ssh -i $PRIVATE_KEY $SSH_USER@$host $command
}

function scpcommand()
{
  file=$1
  host=$2
  scp -q -i $PRIVATE_KEY $file $SSH_USER@$host:.
}

function closure()
{
  if [ $1 -eq 0 ]; then
    echo OK
  else
    echo KO
    exit 1
  fi
}
#=========================================================#
#          Copy Kubeadm Config on all nodes
#=========================================================#
separator "Copy Kubeadm Config on all nodes"
cat > /tmp/kubeadm-config.yml <<EOT 
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: "${NLB_DNS_NAME}:${NLB_PORT}"
EOT
for instance in $${MASTERS[@]}; do
  echo -n "$instance..."
  scpcommand /tmp/kubeadm-config.yml $instance >> $LOGFILE
  closure $?
done
for instance in $${WORKERS[@]}; do
  echo -n "$instance..."
  scpcommand /tmp/kubeadm-config.yml $instance  >> $LOGFILE
  closure $?
done

#=========================================================#
# Reset controllers if flag set
#=========================================================#
separator "Reset cluster (controller nodes)"
if [[ $* == *--reset-controllers* ]]; then
command="sudo kubeadm reset --force && sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X"
for instance in $${MASTERS[@]}; do
  echo -n "$instance..."
  sshcommand "$command" $instance  >> $LOGFILE
  closure $?
done
rm cluster.state
fi

#=========================================================#
# Reset workers if flag set
#=========================================================#
separator "Reset cluster (worker nodes)"
if [[ $* == *--reset-workers* ]]; then
command="sudo kubeadm reset --force && sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X"
for instance in $${WORKERS[@]}; do
  echo -n "$instance..."
  sshcommand "$command" $instance  >> $LOGFILE
  closure $?
done
fi

#=========================================================#
# Initialise cluster
#=========================================================#
if ! grep -q "\-\-control-plane" cluster.state; then
separator "Initialise cluster"
command="sudo kubeadm init --config=/home/ec2-user/kubeadm-config.yml --upload-certs"
sshcommand "$command" $${MASTERS[0]} > cluster.state
closure $?
fi

#=========================================================#
#      Configure Kubectl on controller[0] node
#=========================================================#
separator "Configure user for kubectl on controller[0] node"
command="
mkdir -p \$HOME/.kube &&
sudo cp /etc/kubernetes/admin.conf \$HOME/.kube/config &&
sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config"
sshcommand "$command" $${MASTERS[0]}  >> $LOGFILE
closure $?
#=========================================================#
#                Install Calico
#=========================================================#
separator "Install Calico"
command="kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml"
sshcommand "$command" $${MASTERS[0]}  >> $LOGFILE
closure $?

#=========================================================#
# Join other controllers
#=========================================================#
separator "Join controller nodes"
command="sudo "
command+=$(grep -E "\s+kubeadm join\s" cluster.state -A2) 
command=$(echo $command | sed 's/\\//g' | tr '\n' ' ')
for instance in $${MASTERS[@]}; do
  echo -n "$instance..."
  sshcommand "$command" $instance  >> $LOGFILE
  closure $?
done

#=========================================================#
#                     Join workers
#=========================================================#
separator "Join worker nodes"
command="sudo "
command+=$(grep -E "^kubeadm\s" cluster.state -A2) 
command=$(echo $command | sed 's/\\//g' | tr '\n' ' ')
for instance in $${WORKERS[@]}; do
  echo -n "$instance..."
  sshcommand "$command" $instance >> $LOGFILE
  closure $?
done

#=========================================================#
#           Configure kubectl on all controllers
#=========================================================#
separator "Configure kubectl on all controllers"
command="
mkdir -p \$HOME/.kube &&
sudo cp /etc/kubernetes/admin.conf \$HOME/.kube/config &&
sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config"
for instance in $${MASTERS[*]:1}; do
  echo -n "$instance..."
  sshcommand "$command" $instance  >> $LOGFILE
  closure $?
done

#=========================================================#
# Get nodes
#=========================================================#
separator "Get nodes"
command="kubectl get nodes"
sshcommand "$command" $${MASTERS[0]}
closure $?

#=========================================================#
#       Configure local user for kubectl
#=========================================================#
separator "Configure local user for kubectl"
command="sudo cat /etc/kubernetes/admin.conf"
sshcommand "$command" $${MASTERS[0]} > $HOME/.kube/config
closure $?