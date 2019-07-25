kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=/var/lib/kubernetes/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=/var/lib/kubernetes/admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=/var/lib/kubernetes/admin.pem \
  --client-key=/var/lib/kubernetes/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=/var/lib/kubernetes/admin.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=admin \
  --kubeconfig=/var/lib/kubernetes/admin.kubeconfig

kubectl config use-context default --kubeconfig=/var/lib/kubernetes/admin.kubeconfig
