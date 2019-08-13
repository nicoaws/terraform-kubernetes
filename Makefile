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

dashboard:
	kubectl apply -f kubernetes/apps/dashboard/