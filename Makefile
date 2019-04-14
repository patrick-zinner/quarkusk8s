K8S_DIR := k8s
IMAGE_TAG := $(shell /bin/date "+%Y-%m-%d---%H-%M-%S")
INGRESS_HOST = quarkus.$(shell minikube ip).nip.io

MAKE_ENV += IMAGE_TAG INGRESS_HOST
SHELL_EXPORT := $(foreach v,$(MAKE_ENV),$(v)='$($(v))' )

namespace:
	kubectl create ns q8s || true

kafka:
	kubectl apply -f ${K8S_DIR}/strimzi-operator.yaml
	kubectl apply -f ${K8S_DIR}/kafka.yaml

build:
	@eval $$(minikube docker-env) ;\
	docker image prune -a -f
	mvn package -DimageTag=${IMAGE_TAG}

deploy: namespace
	$(SHELL_EXPORT) envsubst < $(K8S_DIR)/quarkusk8s.yaml > /tmp/quarkusk8s.yaml
	kubectl apply -f /tmp/quarkusk8s.yaml

build-deploy: build deploy

delete:
	kubectl delete ns q8s --wait=true || true

setup: namespace build kafka deploy

clean-setup: delete setup
