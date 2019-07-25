kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=/var/lib/kubernetes/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=/var/lib/kubernetes/kube-controller-manager.pem \
  --client-key=/var/lib/kubernetes/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-controller-manager \
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig
