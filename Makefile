.PHONY: pre-commit
SHELL = /bin/bash -o pipefail
PROJECT_PATH ?= $(shell 'pwd')

DOCKER_IMAGE ?= cloudkats/artilleryio:latest

help:
	@grep -E '^[/\a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: ## Commit hooks setup
	@pre-commit install
	@pre-commit gc
	@pre-commit autoupdate

validate: ## Validate with pre-commit hooks
	@pre-commit run --all-files

change: ## Update changelog
	git-chglog -o CHANGELOG.md --next-tag `semtag final -s minor -o`

docker/inspect: ## Inspect container
	@docker run --rm -it \
		-v ${PROJECT_PATH}/simulations:/opt/simulations/ \
		-w /opt/simulations \
		$(DOCKER_IMAGE) /bin/bash

choose/simulation: ## Show all simulations
	@docker run --rm -i \
		-v ${PROJECT_PATH}/simulations:/opt/simulations/ \
		-w /opt/simulations \
		$(DOCKER_IMAGE) \
		artillery run - <./simulations/initial.yaml
