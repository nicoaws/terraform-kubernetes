join_command=$1
if [[  $(pgrep kubelet) ]]; then 
  echo "Kubernetes is already running on this node...skipping."
else
  # Configure sysctl
  # sudo echo "net.bridge.bridge-nf-call-iptables = 1" >>  /etc/sysctl.conf 
  # sudo sysctl -p >> node.log 2>&1
  eval $join_command
fi                    