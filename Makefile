TERRAFORM=./scripts/terraform
PLAN=terraform-plan.out

clean:
	rm -f ${PLAN}
	rm -Rf .terraform/

init: clean
	$(TERRAFORM) init

validate:
	$(TERRAFORM) validate

plan:
	$(TERRAFORM) plan -out=$(PLAN)

apply:
	$(TERRAFORM) apply -auto-approve=true $(PLAN)

.PHONY: clean init generate-secret-vars-file validate plan apply
