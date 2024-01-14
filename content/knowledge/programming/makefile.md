---
title: Makefile
summary: Notes on working with Makefiles
---

## My Makefiles

{{< alert >}}
You can find some of my Makefiles I use for different purposes in my [toolbox](https://github.com/Allaman/toolbox/tree/main/makefile) repository
{{< /alert >}}

## Run shell commands

```makefile
DOCKER_GID=$(shell getent group docker | cut -d: -f3)
```

## Assign output of shell commands to a variable

```makefile
	$(eval NAME=$(shell hostname))
    echo "Hostname is $(NAME)"
```

## echo

Prefixing with `@` does not print out the command itself

```makefile
	@echo "Spinning up the cluster"
	kind create cluster --config kind.yaml
```

## User defined function

```makefile
define get_conf
$(shell yq -r .$(1) conf.yml)
endef
NAME:=$(call get_conf,name)
```

## Concat variables

```makefile
BUILDARGS=--build-arg uid=$(UID) --build-arg gid=$(GID)
BUILDARGS:=$(BUILDARGS) --build-arg docker_gid=$(DOCKER_GID)
BUILDARGS:=$(BUILDARGS) --build-arg name=$(NAME)
```

Concat string

```makefile
	EDITOR += -c 'set syntax=yaml' -
```

## IF

**Simple if**

```makefile
ifeq ($(MOUNT_AWS_FOLDER), true)
MOUNT:=${MOUNT} -v $$HOME/.aws/:/home/${NAME}/.aws
endif
```

**Bash oneliner**

```makefile
	@if [ "$(TARGET)" == "" ]; then echo "Missing target variable - run make targets for possible values"; exit 1; fi
```

**Search for string**

```makefile
EDITOR:=$(shell type -p nvim || echo vim)
ifneq (,$(findstring vim,$(EDITOR)))
	EDITOR += -c 'set syntax=yaml' -
else
	EDITOR:=less
endif
```

## Wait for something

```makefile
	@while [[ "$$(kubectl get -n kube-system deployment/sealed-secrets-controller -o json | jq '.status.readyReplicas')" != "1" ]]; do sleep 5; done
```

## Help message

```makefile
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help
```

This allows something like the following where everything after `##` is printed as help message

```makefile
build: ## Build the container
	@echo 'Building image'
	docker build $(BUILDARGS) -t $(NAME) .
```
