gen-req:
	pipenv requirements > requirements.txt
	pipenv requirements --dev > requirements-dev.txt

