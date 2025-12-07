# SPDX-FileCopyrightText: © 2025 Clifford Weinmann <https://www.cliffordweinmann.com/>
#
# SPDX-License-Identifier: MIT-0

# Set current versions
# REGISTRY_NAME := ghcr.io
# REGISTRY_USER := clifford2
# REPOBASE := $(REGISTRY_NAME)/$(REGISTRY_USER)
IMGBASENAME := vigil-local
IMGRELNAME := $(REPOBASE)/$(IMGBASENAME)
VIGIL_LOCAL_VER := 1.2.6
RELEASE_VERSION := 1
GIT_TAG := $(VIGIL_LOCAL_VER)-$(RELEASE_VERSION)
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
	BUILD_NOLOAD := docker buildx build -f Containerfile
	BUILD_CMD := $(BUILD_NOLOAD) --load
endif


.PHONY: help
help:
	@echo "VIGIL_LOCAL_VER = [$(VIGIL_LOCAL_VER)]"
	@echo "RELEASE_VERSION = [$(RELEASE_VERSION)]"
	@echo "BUILD_DATE = [$(BUILD_DATE)]"
	@echo "IMAGE_RELEASE = [$(IMAGE_RELEASE)]"
	@echo "IMAGE_VERSION = [$(IMAGE_VERSION)]"
	@echo "There is no default target for $(IMGBASENAME):$(IMAGE_VERSION) yet - please pick a suitable target manually"
	@echo "We're using $(CONTAINER_ENGINE) on $(BUILDARCH)"

.PHONY: build
build: .check-depends
	$(BUILD_CMD) --pull --build-arg VIGIL_LOCAL_VER=$(VIGIL_LOCAL_VER) --build-arg BUILD_DATE=$(BUILD_DATE) --build-arg BUILD_TIME=$(BUILD_TIME) --build-arg IMAGE_VERSION=$(IMAGE_VERSION) -t $(IMGBASENAME):$(IMAGE_VERSION) .
	$(CONTAINER_ENGINE) run --rm -t $(IMGBASENAME):$(IMAGE_VERSION) vigil-local --version

.PHONY: tag
tag:
	$(CONTAINER_ENGINE) tag $(IMGBASENAME):$(IMAGE_VERSION) $(IMGRELNAME):$(IMAGE_VERSION)
	$(CONTAINER_ENGINE) tag $(IMGBASENAME):$(IMAGE_VERSION) $(IMGRELNAME):v$(VIGIL_LOCAL_VER)
	$(CONTAINER_ENGINE) tag $(IMGBASENAME):$(IMAGE_VERSION) $(IMGRELNAME):latest

.PHONY: push
push: .check-depends tag
	test ! -z "$(REGISTRY_NAME)" && $(CONTAINER_ENGINE) login -u $(REGISTRY_USER) $(REGISTRY_NAME)|| echo 'Not logging into registry'
	$(CONTAINER_ENGINE) push $(IMGRELNAME):$(IMAGE_VERSION)
	$(CONTAINER_ENGINE) push $(IMGRELNAME):v$(VIGIL_LOCAL_VER)
	$(CONTAINER_ENGINE) push $(IMGRELNAME):latest

.PHONY: all
all: build push

.PHONY: .git-commit
.git-commit: .check-git-deps
	@git add .
	@git commit

.PHONY: .git-tag
.git-tag: .check-git-deps
	@git tag -m "Version $(GIT_TAG)" "$(GIT_TAG)"

.PHONY: .git-push
.git-push: .check-git-deps
	@git push --follow-tags

# git tag & push
.PHONY: git-tag-push
git-tag-push: .git-tag .git-push

# git commit, tag & push
.PHONY: git-commit-tag-push
git-commit-tag-push: .git-commit .git-tag .git-push

# Verify that we have git installed
.PHONY: .check-git-deps
.check-git-deps:
	command -v git

# Verify that we have all required dependencies installed
.PHONY: .check-depends
.check-depends:
	command -v podman || command -v docker
