kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=/var/lib/kubernetes/ca.pem \
  --embed-certs=true \
  --server=https://{{ kubeapi_nlb_dns_name }}:{{ kubeapi_nlb_port }} \
  --kubeconfig=/var/lib/kubernetes/kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
  --client-certificate=/var/lib/kubernetes/kube-proxy.pem \
  --client-key=/var/lib/kubernetes/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=/var/lib/kubernetes/kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-proxy \
  --kubeconfig=/var/lib/kubernetes/kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=/var/lib/kubernetes/kube-proxy.kubeconfig
