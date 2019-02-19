
IMAGE='jenkins-infra/datadog'
TAG='latest'

build:
	docker build -t $(IMAGE):$(TAG) .

shell:
	docker run -i -t -e DD_API_KEY=XXX  --rm --entrypoint /bin/bash $(IMAGE):$(TAG)

clean:
	docker rmi $(IMAGE):$(TAG)

run:
	docker run -i -t -e DD_API_KEY=XXX --name custom-datadog --rm $(IMAGE):$(TAG)
