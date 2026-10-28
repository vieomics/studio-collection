VERSION := 2026-10-26
TAG ?= $(VERSION)
ifeq ($(strip $(TAG)),)
TAG := $(VERSION)
endif
IMAGE_NAME ?= nttg8100/omicslab-jupyterlab
IMAGE := $(IMAGE_NAME):$(TAG)

CONTEXT := .
DOCKERFILE := Dockerfile
CONTAINER ?= $(notdir $(CURDIR))-dev
PORT ?= 8888

PIXI_VERSION ?= 0.83.0
PYTHON_VERSION ?= 3.13
R_VERSION ?= 4.5.3

.ONESHELL:
.PHONY: dev start test stop publish

dev:
	docker build $(CONTEXT) -f $(DOCKERFILE) -t $(IMAGE) \
		--build-arg PIXI_VERSION=$(PIXI_VERSION) \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg R_VERSION=$(R_VERSION)

start: dev
	set -e
	docker rm -f $(CONTAINER) 2>/dev/null || true
	docker run --rm --name $(CONTAINER) -p $(PORT):8888 -d $(IMAGE)

test:
	set -e
	for _ in $$(seq 1 90); do
		if curl -fsS -o /dev/null http://127.0.0.1:$(PORT)/lab 2>/dev/null; then
			break
		fi
		sleep 2
	done
	curl -fsS -o /dev/null http://127.0.0.1:$(PORT)/lab
	curl -fsS http://127.0.0.1:$(PORT)/api/kernelspecs | grep -q python-pixi
	curl -fsS http://127.0.0.1:$(PORT)/api/kernelspecs | grep -q ir-pixi
	docker exec $(CONTAINER) sh -c 'test "$$SHELL" = /usr/bin/zsh'
	docker exec $(CONTAINER) zsh -ic 'echo $$ZSH' | grep -q /opt/oh-my-zsh
	docker exec $(CONTAINER) zsh -ic 'echo "plugins=($$plugins)"' | grep -q zsh-syntax-highlighting
	docker exec $(CONTAINER) grep -q '/opt/jupyter' /usr/local/share/jupyter/kernels/python-pixi/kernel.json
	docker exec $(CONTAINER) grep -q '/opt/r-kernel' /usr/local/share/jupyter/kernels/ir-pixi/kernel.json
	docker exec $(CONTAINER) /opt/jupyter/.pixi/envs/default/bin/python -c 'import ipykernel'
	docker exec $(CONTAINER) /opt/r-kernel/.pixi/envs/default/bin/Rscript -e 'stopifnot(requireNamespace("IRkernel", quietly = TRUE))'
	docker exec $(CONTAINER) pixi --version
	docker exec $(CONTAINER) sh -c 'ps -ef | grep -q "[j]upyter"'

stop:
	docker rm -f $(CONTAINER) 2>/dev/null || true

publish: dev
	docker push $(IMAGE)
