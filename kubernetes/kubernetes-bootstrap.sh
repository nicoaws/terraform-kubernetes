#!/bin/bash

source `dirname "$0"`/hosts

ALL_NODES=("${MASTERS[@]}" "${WORKERS[@]}")
PRIVATE_KEY=~/.ssh/id_rsa
SSH_USER=ec2-user
LOGFILE=kubernetes-bootstrap.log


if [[ $* == *reset-cluster=True* ]]; then RESET_CLUSTER="True" ; else RESET_CLUSTER="False" ; fi
if [[ $* == *reset-controllers=True* ]]; then RESET_CONTROLLERS="True" ; else RESET_CONTROLLERS="False" ; fi
if [[ $* == *reset-workers=True* ]]; then RESET_WORKERS="True" ; else RESET_WORKERS="False" ; fi

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

function copycommand()
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

if [[ ! $* == *skip-bundle-upload=True* ]]; then
#=========================================================#
#               Generate Kubeadm Config
#=========================================================#
cat > `dirname "$0"`/scripts/kubeadm-config.yml <<EOT 
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: "$NLB_DNS_NAME:$NLB_PORT"
EOT
tar -zcf /tmp/scripts.tar.gz `dirname "$0"`/scripts/*

#=========================================================#
#        Copy and extract scripts on all nodes
#=========================================================#
separator "Copy remote bundle on all nodes"
for instance in ${ALL_NODES[@]} ; do
  echo -n "$instance..."
  copycommand /tmp/scripts.tar.gz $instance >> $LOGFILE 2>&1
  closure $?
done

separator "Extract remote bundle on all nodes"
command="tar -zxf scripts.tar.gz --strip-components=2"
for instance in ${ALL_NODES[@]} ; do
  echo -n "$instance..."
  sshcommand "$command" $instance
  closure $?
done
fi

#=========================================================#
# Reset controllers (if required)
#=========================================================#
if [[ $RESET_CLUSTER == "True" ]] || [[ $RESET_CONTROLLERS == "True" ]]; then
  separator "Resetting controller nodes"
  for instance in ${MASTERS[*]:1}; do
    command="/home/ec2-user/reset-node.sh"
    echo -n "Kubeadm reset: $instance..."
    sshcommand "$command" $instance
    closure $?
  done
  if [[ $RESET_CLUSTER == "False" ]]; then
    echo -n "Waiting for NLB healthchecks to converge..."
    sleep 30
    closure $?
  fi
fi

#=========================================================#
# Reset workers (if required)
#=========================================================#
if [[ $RESET_CLUSTER == "True" ]] || [[ $RESET_WORKERS == "True" ]]; then
  separator "Resetting worker nodes"
  for instance in ${WORKERS[@]}; do
    command="/home/ec2-user/reset-node.sh"
    echo -n "Kubeadm reset: $instance..."
    sshcommand "$command" $instance 
    closure $?
  done
fi

#=========================================================#
# Initialise cluster (if required)
#=========================================================#
separator "Initialise cluster (if required)"
command="/home/ec2-user/init-cluster.sh --reset-cluster=$RESET_CLUSTER"
sshcommand "$command" ${MASTERS[0]} > /tmp/commands.txt 2>&1
control_plane_join_command="$(head -n1 /tmp/commands.txt | grep control-plane) > node.log 2>&1"
workers_join_command="$(tail -n1 /tmp/commands.txt | grep join | grep -v control-plane) > node.log 2>&1"
closure $?

#=========================================================#
#                Join other controllers
#=========================================================#
separator "Join controller nodes"
for instance in ${MASTERS[*]:1}; do
  echo -n "$instance..."
  sshcommand "/home/ec2-user/join-node.sh \"$control_plane_join_command\"" $instance
  closure $?
done

# #=========================================================#
# #                     Join workers
# #=========================================================#
separator "Join worker nodes"
for instance in ${WORKERS[@]}; do
  echo -n "$instance..."
  sshcommand "/home/ec2-user/join-node.sh \"$workers_join_command\"" $instance
  closure $?
done

#=========================================================#
#           Configure kubectl on all controllers
#=========================================================#
separator "Configure kubectl on all controllers"
command="/home/ec2-user/kubectl-config.sh"
for instance in ${MASTERS[*]:1}; do
  echo -n "$instance..."
  sshcommand "$command" $instance
  closure $?
done

#=========================================================#
#       Configure local user for kubectl
#=========================================================#
separator "Configure local user for kubectl"
command="sudo cat /etc/kubernetes/admin.conf"
mkdir -p $HOME/.kube
sshcommand "$command" ${MASTERS[0]} > $HOME/.kube/terrakube-config
closure $?