VERSION := 4.6.1
TAG ?= $(VERSION)
ifeq ($(strip $(TAG)),)
TAG := $(VERSION)
endif
IMAGE_NAME ?= nttg8100/omicslab-rstudio
IMAGE := $(IMAGE_NAME):$(TAG)

CONTEXT := .
DOCKERFILE := Dockerfile
CONTAINER ?= $(notdir $(CURDIR))-dev
PORT ?= 8787

PIXI_VERSION ?= 0.83.0
R_PIXI_VERSION ?= 4.6.1

.ONESHELL:
.PHONY: dev start test stop publish

dev:
	docker build $(CONTEXT) -f $(DOCKERFILE) -t $(IMAGE) \
		--build-arg RSTUDIO_VERSION=$(VERSION) \
		--build-arg PIXI_VERSION=$(PIXI_VERSION) \
		--build-arg R_PIXI_VERSION=$(R_PIXI_VERSION)

start: dev
	set -e
	docker rm -f $(CONTAINER) 2>/dev/null || true
	docker run --rm --name $(CONTAINER) -p $(PORT):8787 -d $(IMAGE)

test:
	set -e
	rm -f /tmp/rstudio-ci-cookies
	for _ in $$(seq 1 90); do
		if curl -fsS -o /dev/null http://127.0.0.1:$(PORT)/ 2>/dev/null; then
			break
		fi
		sleep 2
	done
	curl -fsS -o /dev/null http://127.0.0.1:$(PORT)/
	curl -sS -c /tmp/rstudio-ci-cookies -b /tmp/rstudio-ci-cookies \
		-L --max-redirs 10 http://127.0.0.1:$(PORT)/ | grep -qi RStudio
	docker exec $(CONTAINER) sh -c 'test "$$SHELL" = /usr/bin/zsh'
	docker exec $(CONTAINER) zsh -ic 'echo $$ZSH' | grep -q /opt/oh-my-zsh
	docker exec $(CONTAINER) zsh -ic 'echo "plugins=($$plugins)"' | grep -q zsh-syntax-highlighting
	docker exec $(CONTAINER) R --version | grep -q '4.6.1'
	docker exec $(CONTAINER) sh -c 'command -v R | grep -q /opt/r-pixi'
	docker exec $(CONTAINER) Rscript -e 'stopifnot(requireNamespace("rstudioapi", quietly = TRUE)); stopifnot(requireNamespace("BiocManager", quietly = TRUE))'
	docker exec $(CONTAINER) grep -q 'bioconda' /opt/r-pixi/pixi.toml
	docker exec $(CONTAINER) grep -q 'rsession-which-r=/opt/r-pixi/.pixi/envs/default/bin/R' /etc/rstudio/rserver.conf
	docker exec $(CONTAINER) sh -c 'ps -ef | grep -q "[r]server"'

stop:
	docker rm -f $(CONTAINER) 2>/dev/null || true

publish: dev
	docker push $(IMAGE)
