MAKEFLAGS += --silent

ENV_FILE := dev.env
-include ${ENV_FILE}
export

# Environment Vars
PROJECT_PATH := $(shell git config --get remote.origin.url | sed -e 's/.git//; s/git@//; s/:/\//')
PROJECT_NAME := $(notdir $(shell pwd))
PROJECT_SOURCE = $(shell find . -type f -name '*.go' -not -path "./vendor/*")
GOBIN := ${GOPATH}/bin
PWD := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
DIST_DIR := $(CURDIR)/bin

# Build Vars
BUILD_VERSION := $(shell git describe --always --dirty)

# Linker Flags
LINKER_FLAGS := -X env.Version=$(BUILD_VERSION)


all: help

## build-all: Builds all architectures of the application.
build-all: build build-linux build-windows

## build: Build the application.
build: ${PROJECT_NAME}

## build-linux: Build the application targeting a Linux environment.
build-linux:
	echo "Building '${PROJECT_NAME}' for Linux environment..."
	GOOS=linux GOARCH=amd64 go build -ldflags='$(LINKER_FLAGS)' -v -o ${DIST_DIR}/${PROJECT_NAME}-linux
	echo

## build-linux: Build the application targeting a Windows environment.
build-windows:
	echo "Building '${PROJECT_NAME}' for Windows environment..."
	GOOS=windows GOARCH=386 go build -ldflags='$(LINKER_FLAGS)' -v -o ${DIST_DIR}/${PROJECT_NAME}.exe
	echo

## clean: Remove all build artifacts and generated files.
clean:
	rm -rf ${DIST_DIR}
	rm -rf vendor
	rm -f Gopkg.lock
	go clean -x

## help: Print out a list of available build targets.
help:
	echo "Make targets available for '${PROJECT_NAME}'"
	echo
	sed -n 's/^##//p' ${PWD}/Makefile | column -t -s ':' | sed -e 's/^/ /'
	echo

## test: Test the application.
test: build
	echo "Testing '${PROJECT_NAME}'..."
	go mod tidy
	go test ./... -coverprofile=unit-test-coverage.out
	go tool cover -html=unit-test-coverage.out
	echo

${GOBIN}/dep:
	echo "Installing 'Dep'"
	curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
	echo

${PROJECT_NAME}: Makefile ${PROJECT_SOURCE}
	echo "Building '${PROJECT_NAME}'..."
	go fmt ./...
	go vet ./...
	go build -ldflags='$(LINKER_FLAGS)' -v -o ${DIST_DIR}/${PROJECT_NAME}
	echo

# Demo Targets
deep-clean: clean
	rm -rf ${GOBIN}/dep
	rm -rf ${GOBIN}/gocov

.PHONY: build-all build build-linux build-windows clean deep-clean help test vet
