kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://{{ kubeapi_nlb_dns_name }}:{{ kubeapi_nlb_port }} \
  --kubeconfig={{ inventory_hostname }}.kubeconfig

kubectl config set-credentials system:node:{{ inventory_hostname }} \
  --client-certificate={{ inventory_hostname }}.pem \
  --client-key={{ inventory_hostname }}-key.pem \
  --embed-certs=true \
  --kubeconfig={{ inventory_hostname }}.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes-the-hard-way \
  --user=system:node:{{ inventory_hostname }} \
  --kubeconfig={{ inventory_hostname }}.kubeconfig

kubectl config use-context default --kubeconfig={{ inventory_hostname }}.kubeconfig