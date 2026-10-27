VERSION := 4.143.1
TAG ?= $(VERSION)
ifeq ($(strip $(TAG)),)
TAG := $(VERSION)
endif
IMAGE_NAME ?= nttg8100/omicslab-code-server
IMAGE := $(IMAGE_NAME):$(TAG)

CONTEXT := .
DOCKERFILE := Dockerfile
CONTAINER ?= $(notdir $(CURDIR))-dev
PORT ?= 8080

PIXI_VERSION ?= 0.83.0
OPENCODE_VERSION ?= 2.2.0
NFCORE_EXTENSIONPACK_VERSION ?= 0.8.0

.ONESHELL:
.PHONY: dev start test stop publish

dev:
	docker build $(CONTEXT) -f $(DOCKERFILE) -t $(IMAGE) \
		--build-arg STUDIO_VERSION=$(VERSION) \
		--build-arg PIXI_VERSION=$(PIXI_VERSION) \
		--build-arg OPENCODE_VERSION=$(OPENCODE_VERSION) \
		--build-arg NFCORE_EXTENSIONPACK_VERSION=$(NFCORE_EXTENSIONPACK_VERSION)

start: dev
	set -e
	docker rm -f $(CONTAINER) 2>/dev/null || true
	docker run --rm --name $(CONTAINER) -p $(PORT):8080 -d $(IMAGE)

test:
	set -e
	for _ in $$(seq 1 60); do
		if curl -fsS http://127.0.0.1:$(PORT)/healthz >/dev/null 2>&1; then
			break
		fi
		sleep 2
	done
	curl -fsS http://127.0.0.1:$(PORT)/healthz >/dev/null
	test "$$(curl -sSL -o /dev/null -w '%{http_code}' http://127.0.0.1:$(PORT)/)" = "200"
	docker logs $(CONTAINER) 2>&1 | grep -q "Authentication is disabled"
	docker exec $(CONTAINER) sh -c 'test "$$SHELL" = /usr/bin/zsh'
	docker exec $(CONTAINER) zsh -ic 'echo $$ZSH' | grep -q /opt/oh-my-zsh
	docker exec $(CONTAINER) zsh -ic 'echo $$plugins' | grep -q zsh-syntax-highlighting
	docker exec $(CONTAINER) code-server --list-extensions | grep -qx nf-core.nf-core-extensionpack
	docker exec $(CONTAINER) pixi --version
	docker exec $(CONTAINER) opencode --version

stop:
	docker rm -f $(CONTAINER) 2>/dev/null || true

publish: dev
	docker push $(IMAGE)
