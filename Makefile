# SPDX-FileCopyrightText: © 2025 Clifford Weinmann <https://www.cliffordweinmann.com/>
#
# SPDX-License-Identifier: MIT-0

# Use podman or docker?
ifeq ($(shell command -v podman 2> /dev/null),)
	CONTAINER_ENGINE := docker
else
	CONTAINER_ENGINE := podman
endif

# Configure build commands
ifeq ($(CONTAINER_ENGINE),podman)
	BUILDARCH := $(shell podman version --format '{{.Client.OsArch}}' | cut -d/ -f2)
	BUILD_NOLOAD := podman build
	BUILD_CMD := $(BUILD_NOLOAD) --dns 1.1.1.1
else
	BUILDARCH := $(shell docker version --format '{{.Client.Arch}}')
	BUILD_NOLOAD := docker buildx build
	BUILD_CMD := $(BUILD_NOLOAD) --load
endif
# Get current versions
IMAGE_NAME := docker.io/cliffordw/vigil-local
VIGIL_LOCAL_VER := $(shell grep '^ARG VIGIL_LOCAL_VER' Containerfile | cut -d= -f2)
RELEASE_VERSION := 1
IMAGE_TAG := v$(VIGIL_LOCAL_VER)-$(RELEASE_VERSION)


.PHONY: hello
hello:
	@echo "There is no default target for $(IMAGE_NAME):$(IMAGE_TAG) yet - please pick a suitable target manually"
	@echo "We're using $(CONTAINER_ENGINE) on $(BUILDARCH)"

.PHONY: build
build:
	$(BUILD_CMD) --pull -t $(IMAGE_NAME):$(IMAGE_TAG) .

.PHONY: git-push
git-push:
	@git add .
	@git commit
	@git tag "$(IMAGE_TAG)"
	@git push --follow-tags

.PHONY: docker-push
docker-push:
	$(CONTAINER_ENGINE) login docker.io
	$(CONTAINER_ENGINE) push $(IMAGE_NAME):$(IMAGE_TAG)
	$(CONTAINER_ENGINE) tag $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_NAME):v$(VIGIL_LOCAL_VER)
	$(CONTAINER_ENGINE) push $(IMAGE_NAME):v$(VIGIL_LOCAL_VER)
	$(CONTAINER_ENGINE) tag $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_NAME):latest
	$(CONTAINER_ENGINE) push $(IMAGE_NAME):latest
