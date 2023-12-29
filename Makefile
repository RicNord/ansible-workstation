gen-req:
	pipenv requirements > requirements.txt
	pipenv requirements --dev > requirements-dev.txt

install:
	/bin/bash ./run-ansible.sh
