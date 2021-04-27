TERRAFORM_BIN ?= terraform
PLAN ?= terraform-plan.out

all: clean plan apply

clean:
	rm -Rf .terraform/ $(PLAN)

init: .terraform/plugins/selections.json

validate: .terraform/plugins/selections.json
	terraform fmt -recursive -check
	$(TERRAFORM_BIN) validate plans
	tfsec --exclude-downloaded-modules

plan: .terraform/plugins/selections.json
	$(TERRAFORM_BIN) plan -out=$(PLAN) plans

apply: .terraform/plugins/selections.json
	$(TERRAFORM_BIN) apply -auto-approve=true $(PLAN)

destroy:
	$(TERRAFORM_BIN) destroy -auto-approve=true plans

.PHONY: apply clean destroy init plan validate

.terraform/plugins/selections.json:
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
