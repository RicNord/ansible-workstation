gen-req:
	pipenv requirements > requirements.txt
	pipenv requirements --dev > requirements-dev.txt

install:
	/bin/bash ./run-ansible.sh

test:
	bash -c "tests/test-runner.sh"

clean-instance:
	bash -c "incus list --project ansible-ws --format csv --columns n | xargs incus delete --force --project ansible-ws"

clean: clean-instance
	bash -c "terraform -chdir=tests/terraform destroy -auto-approve"

.PHONY: submodules
submodules: ## Pull and update git submodules recursively
	@echo "+ $@"
	@git pull --recurse-submodules
	@git submodule update --init --recursive
