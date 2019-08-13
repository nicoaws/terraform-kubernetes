PLAN_FILE = plan.out


.PHONY: init plan apply destroy deploy-cluster dashboard traefik

init: 
	terraform init
	
plan:
	terraform plan -out $(PLAN_FILE)

apply: 
	terraform apply $(PLAN_FILE)

clean:
	terraform destroy --force
	rm -rf .kube/
	rm -rf kubernetes/hosts

deploy-cluster:
	bash kubernetes/kubernetes-bootstrap.sh

reset-cluster:
	bash kubernetes/kubernetes-bootstrap.sh --reset-cluster=True

reset-controllers:
	bash kubernetes/kubernetes-bootstrap.sh --reset-controllers=True

traefik:
	# kubectl delete -f kubernetes/apps/traefik/
	kubectl apply -f kubernetes/apps/traefik/

dashboard:
	# kubectl delete -f kubernetes/apps/dashboard/
	kubectl apply -f kubernetes/apps/dashboard/
	kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')