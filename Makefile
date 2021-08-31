SHELL=/usr/bin/env bash
PLAN_OPTIONS ?=
APPLY_OPTIONS ?=
MAKEFILE_PATH := $(notdir $(CURDIR))
EXCLUDE ?=
INCLUDE ?=

define PLAN_OPTIONS_EXCLUDE
	$(shell terraform show -no-color current.plan | perl -nle 'if (/\s# (.*?)\s/) {print $$1}' | grep -E -v '$(1)' | sed -e 's/^/-target="/g' -e 's/$$/"/g' | xargs)
endef

define PLAN_OPTIONS_INCLUDE
	$(shell terraform show -no-color current.plan | perl -nle 'if (/\s# (.*?)\s/) {print $$1}' | grep -E '$(1)' | sed -e 's/^/-target="/g' -e 's/$$/"/g' | xargs)
endef

.PHONY: up down health clean init plan plan_include plan_exclude test apply destroy

#if make is typed with no further arguments, then show a list of available targets
default:
	@awk -F\: '/^[a-z_]+:/ && !/default/ {printf "- %-20s %s\n", $$1, $$2}' Makefile

help:
	@echo ""
	@echo " Usage: "
	@echo " Run make plan to show pending changes then pick the resource you want to target and run a plan again to double check"
	@echo " and [INCLUDE|EXCLUDE] support POSIX Extended Regular Expressions (ERE)"
	@echo ""
	@echo " e.g."
	@echo " PLAN_OPTIONS=\"-target=\"aws_iam_policy.ec2-read\"\" make plan"
	@echo " APPLY_OPTIONS=\"-target=\"aws_iam_policy.ec2-read\"\" make apply"
	@echo " make plan_exclude EXCLUDE='rds'"
	@echo " make plan_include INCLUDE='aws_security_group|redis'"
	@echo ""

up:
	docker-compose up -d

down:
	docker-compose down -v

health:
	@curl -s http://localhost:4566/health | jq

clean:
	sudo rm -rf .terraform
	rm -f current.plan
	rm -f *.tf.json

plan_exclude:
	terraform plan -out current.plan $(strip $(call PLAN_OPTIONS_EXCLUDE,$(EXCLUDE)))

plan_include:
	terraform plan -out current.plan $(strip $(call PLAN_OPTIONS_INCLUDE,$(INCLUDE)))

init:
	terraform init

plan: clean init
	terraform plan -out current.plan ${PLAN_OPTIONS}
	terraform show -no-color current.plan > txt.plan

apply: current.plan
	terraform apply -auto-approve ${APPLY_OPTIONS} current.plan 

test:
	terraform fmt -diff=true -write=false

destroy:
	terraform destroy
