PREFIX ?= $(HOME)/bin

OS_ID := $(shell grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
OS_VERSION_ID := $(shell grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

FORCE ?= 0

ifeq ($(FORCE),1)
	PODMAN_BUILD_ARGS = --no-cache
endif

ifeq ($(OS_ID), fedora)
	IMAGE_SOURCE ?= registry.fedoraproject.org/fedora:$(OS_VERSION_ID)
	IMAGE_TAG ?= fedora$(OS_VERSION_ID)
	PKG_MANAGER ?= dnf
else ifeq ($(OS_ID), centos)
	IMAGE_SOURCE ?= centos:stream$(OS_VERSION_ID)
	IMAGE_TAG ?= centos-stream$(OS_VERSION_ID)
	PKG_MANAGER ?= dnf
else ifeq ($(OS_ID), ubuntu)
	IMAGE_SOURCE ?= ubuntu:$(OS_VERSION_ID)
	IMAGE_TAG ?= ubuntu$(OS_VERSION_ID)
	PKG_MANAGER ?= apt
endif

install: build
	mkdir -p $(PREFIX)
	install -m 755 claude $(PREFIX)/claude

build:
	podman build $(PODMAN_BUILD_ARGS) \
		--build-arg IMAGE_SOURCE=$(IMAGE_SOURCE) \
		--build-arg PKG_MANAGER=$(PKG_MANAGER) \
		-t claude:$(IMAGE_TAG) .
	podman tag claude:$(IMAGE_TAG) claude:latest
