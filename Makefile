TERRAFORM=./scripts/terraform
PLAN=terraform-plan.out
TF_SECRET_VARS_FILE=secret.tfvars

clean:
	rm -f ${PLAN}
	rm -f ${TF_SECRET_VARS_FILE}
	rm -Rf .terraform/

init: clean
	$(TERRAFORM) init

generate-secret-vars-file:
	@rm ${TF_SECRET_VARS_FILE}
	@echo "datadog_api_key = \"$${DD_API_KEY}\"" >> ${TF_SECRET_VARS_FILE}
	@echo "datadog_app_key = \"$${DD_APP_KEY}\"" >> ${TF_SECRET_VARS_FILE}
	@chmod 600 ${TF_SECRET_VARS_FILE}

validate: generate-secret-vars-file
	$(TERRAFORM) validate -var-file=${TF_SECRET_VARS_FILE}

plan: generate-secret-vars-file
	$(TERRAFORM) plan -var-file=${TF_SECRET_VARS_FILE} -out=$(PLAN)

apply:
	$(TERRAFORM) apply $(PLAN)

.PHONY: clean init generate-secret-vars-file validate plan apply
