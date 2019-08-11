sudo kubeadm reset --force > /dev/null 2>&1
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X