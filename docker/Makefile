
IMAGE='jenkins-infra/datadog'
TAG='latest'

build:
	docker build -t $(IMAGE):$(TAG) .

shell:
	docker run \
		-i -t \
		-e DD_API_KEY=XXX\
		-v $(PWD)/checks.d:/etc/datadog-agent/checks.d/ \
		-v $(PWD)/conf.d:/etc/datadog-agent/conf.d/ \
		--rm --entrypoint /bin/bash \
		$(IMAGE):$(TAG)

clean:
	find . -name '*.pyc' -delete
	docker rmi $(IMAGE):$(TAG)

run:
	docker run -i -t -e DD_API_KEY=XXX --name custom-datadog --rm $(IMAGE):$(TAG)

check:
	for check in `ls checks.d | sed 's/.py//'`; \
		do docker run \
			-i -t \
			-v $(PWD)/mock/datadog.yaml:/etc/datadog-agent/datadog.yaml\
			--rm \
			$(IMAGE):$(TAG) /opt/datadog-agent/bin/agent/agent check $$check ; \
	    done\
    ;
