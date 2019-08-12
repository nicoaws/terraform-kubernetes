if [[ $* == *reset-cluster=True* ]]; then
  ./reset-node.sh > /dev/null 2>&1
  rm -rf node.log cluster.state
fi

if [[ ! -f cluster.state ]]; then
  sudo kubeadm init --config=kubeadm-config.yml --upload-certs > cluster.state 2>&1
  cat cluster.state >> node.log
fi

# Configure sysctl
sudo echo "net.bridge.bridge-nf-call-iptables = 1" >>  /etc/sysctl.conf 
sudo sysctl -p >> node.log 2>&1


# Configure Kubectl
./kubectl-config.sh >> node.log 2>&1
# Install Calico
./install-calico.sh >> node.log 2>&1

controllers_join_command="sudo $(grep -E '\s+kubeadm join\s' cluster.state -A2 | sed 's/\\//g' | tr '\n' ' ')"
workers_join_command="sudo $(grep -E '^kubeadm\s' cluster.state -A2 | sed 's/\\//g' | tr '\n' ' ')"

echo $controllers_join_command
echo $workers_join_command