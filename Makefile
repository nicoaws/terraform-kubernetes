PLAN_FILE = plan.out


.PHONY: init plan apply destroy deploy-cluster

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