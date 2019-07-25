kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=/var/lib/kubernetes/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=/var/lib/kubernetes/kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=/var/lib/kubernetes/kube-scheduler.pem \
  --client-key=/var/lib/kubernetes/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=/var/lib/kubernetes/kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:kube-scheduler \
  --kubeconfig=/var/lib/kubernetes/kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=/var/lib/kubernetes/kube-scheduler.kubeconfig
