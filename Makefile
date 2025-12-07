# SPDX-FileCopyrightText: © 2025 Clifford Weinmann <https://www.cliffordweinmann.com/>
#
# SPDX-License-Identifier: MIT-0

# Set current versions
IMAGE_NAME := docker.io/cliffordw/vigil-local
VIGIL_LOCAL_VER := 1.2.6
RELEASE_VERSION := 1
# Add date into release version to distinguish between image differences resulting from `apk update` & `apk upgrade` steps
BUILD_DATE := $(shell TZ=UTC date '+%Y-%m-%d')
IMAGE_RELEASE := $(RELEASE_VERSION).$(shell TZ=UTC date '+%Y%m%d')
IMAGE_VERSION := v$(VIGIL_LOCAL_VER)-$(IMAGE_RELEASE)

GIT_REVISION := $(shell git rev-parse @)
BUILD_TIME := $(shell TZ=UTC date '+%Y-%m-%dT%H:%M:%SZ')

# Use podman (preferred) or docker?
ifeq ($(shell command -v podman 2> /dev/null),)
	CONTAINER_ENGINE := docker
else
	CONTAINER_ENGINE := podman
endif

# Configure build commands
ifeq ($(CONTAINER_ENGINE),podman)
	BUILDARCH := $(shell podman version --format '{{.Client.OsArch}}' | cut -d/ -f2)
	BUILD_NOLOAD := podman build
	BUILD_CMD := $(BUILD_NOLOAD)
else
	BUILDARCH := $(shell docker version --format '{{.Client.Arch}}')
	BUILD_NOLOAD := docker buildx build
	BUILD_CMD := $(BUILD_NOLOAD) --load
endif


.PHONY: help
help:
	@echo "VIGIL_LOCAL_VER = [$(VIGIL_LOCAL_VER)]"
	@echo "RELEASE_VERSION = [$(RELEASE_VERSION)]"
	@echo "BUILD_DATE = [$(BUILD_DATE)]"
	@echo "IMAGE_RELEASE = [$(IMAGE_RELEASE)]"
	@echo "IMAGE_VERSION = [$(IMAGE_VERSION)]"
	@echo "There is no default target for $(IMAGE_NAME):$(IMAGE_VERSION) yet - please pick a suitable target manually"
	@echo "We're using $(CONTAINER_ENGINE) on $(BUILDARCH)"

.PHONY: build
build:
	$(BUILD_CMD) --pull --build-arg VIGIL_LOCAL_VER=$(VIGIL_LOCAL_VER) --build-arg BUILD_DATE=$(BUILD_DATE) --build-arg BUILD_TIME=$(BUILD_TIME) --build-arg IMAGE_VERSION=$(IMAGE_VERSION) -t $(IMAGE_NAME):$(IMAGE_VERSION) .
	$(CONTAINER_ENGINE) run --rm -it $(IMAGE_NAME):$(IMAGE_VERSION) vigil-local --version

.PHONY: git-push
git-push:
	@git add .
	@git commit
	@git tag "$(VIGIL_LOCAL_VER)-$(RELEASE_VERSION)"
	@git push --follow-tags

.PHONY: docker-push
docker-push:
	$(CONTAINER_ENGINE) login docker.io
	$(CONTAINER_ENGINE) push $(IMAGE_NAME):$(IMAGE_VERSION)
	$(CONTAINER_ENGINE) tag $(IMAGE_NAME):$(IMAGE_VERSION) $(IMAGE_NAME):v$(VIGIL_LOCAL_VER)
	$(CONTAINER_ENGINE) push $(IMAGE_NAME):v$(VIGIL_LOCAL_VER)
	$(CONTAINER_ENGINE) tag $(IMAGE_NAME):$(IMAGE_VERSION) $(IMAGE_NAME):latest
	$(CONTAINER_ENGINE) push $(IMAGE_NAME):latest
