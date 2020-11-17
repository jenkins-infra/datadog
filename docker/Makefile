IMAGE=jenkinsciinfra/datadog
TAG=7

build:
	docker build -t $(IMAGE):$(TAG) --build-arg TAG="$(TAG)" .

check:
	for check in `ls checks.d | sed 's/.py//'`; \
		do docker run \
			-v $(PWD)/mock/datadog.yaml:/etc/datadog-agent/datadog.yaml\
			--rm \
			$(IMAGE):$(TAG) /opt/datadog-agent/bin/agent/agent check $$check ; \
	    done\
    ;

clean:
	find . -name '*.pyc' -delete
	docker rmi $(IMAGE):$(TAG)


publish:
	docker push $(IMAGE):$(TAG)
	docker push $(IMAGE):latest

shell:
	docker run \
		-i -t \
		-e DD_API_KEY=XXX\
		-v $(PWD)/checks.d:/etc/datadog-agent/checks.d/ \
		-v $(PWD)/conf.d:/etc/datadog-agent/conf.d/ \
		--rm --entrypoint /bin/bash \
		$(IMAGE):$(TAG)
