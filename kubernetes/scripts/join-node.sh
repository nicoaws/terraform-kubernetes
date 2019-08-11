join_command=$1
if [[  $(pgrep kubelet) ]]; then 
  echo "Kubernetes is already running on this node...skipping."
else
  eval $join_command
fi                    