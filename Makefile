TERRAFORM_BIN ?= terraform
PLAN ?= terraform-plan.out

apply:
	$(TERRAFORM_BIN) apply -auto-approve=true $(PLAN)

clean:
	rm -f ${PLAN}
	rm -Rf .terraform/

destroy:
	$(TERRAFORM_BIN) destroy -auto-approve=true plans

init: clean
# Read init variable from credentials: for dev usage. Ask the jenkins-infra team for these credentials
	if [ -f 'credentials' ]; then\
		source ./credentials ;\
	fi; \
	$(TERRAFORM_BIN) init \
		-backend-config="storage_account_name=$$TF_BACKEND_STORAGE_ACCOUNT_NAME" \
		-backend-config="container_name=$$TF_BACKEND_CONTAINER_NAME" \
		-backend-config="key=$$TF_BACKEND_CONTAINER_FILE" \
		-backend-config="access_key=$$TF_BACKEND_STORAGE_ACCOUNT_KEY" \
		-force-copy \
		plans

init-local: clean
	if [ -f './plans/backend.tf' ]; then\
		rm ./plans/backend.tf ;\
	fi; \
	$(TERRAFORM_BIN) init plans

plan: refresh
	$(TERRAFORM_BIN) plan -out=$(PLAN) plans

refresh:
	$(TERRAFORM_BIN) refresh plans

validate:
	$(TERRAFORM_BIN) validate plans


.PHONY: apply clean destroy init init-local plan refresh validate
