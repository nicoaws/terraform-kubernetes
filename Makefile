PLAN_FILE = plan.out


.PHONY: init plan apply destroy deploy-cluster dashboard traefik

init: 
	terraform init
	
plan:
	terraform plan -out $(PLAN_FILE)

apply: 
	terraform apply $(PLAN_FILE)

destroy:
	terraform destroy --force

deploy-cluster:
	bash kubernetes/kubernetes-bootstrap.sh

dashboard:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml

traefik:
	kubectl apply -f kubernetes/apps/traefik/