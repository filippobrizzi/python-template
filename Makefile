.ONESHELL:

#* Variables
SHELL = /bin/bash
ENVIRONEMNT := myenv
CONDA_ACTIVATE=source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate $(ENVIRONEMNT) ;

.PHONY: setup
setup: # Install the python environemnt (to be called only once when first cloning the repo).
	./setup.sh

.PHONY: activate
activate: # Activate the python virtual environment
	@echo "Run the following to activate the environment: "
	@echo "conda activate $(ENVIRONEMNT)"

.PHONY: lock
lock: # Update the dependency graph checking for newer releases.
	$(CONDA_ACTIVATE) poetry lock -n

.PHONY: install
install: # Install the python dependencies.
	$(CONDA_ACTIVATE) poetry install -n
	$(CONDA_ACTIVATE) poetry run mypy --install-types --non-interactive ./my_package/

.PHONY: format
format: # Format the python code inside the my_package folder
	$(CONDA_ACTIVATE) poetry run isort --settings-path pyproject.toml ./my_package/
	$(CONDA_ACTIVATE) poetry run black --config pyproject.toml ./my_package/

.PHONY: check-codestyle
check-codestyle: # Check that the code style of the pyhton code matches the expected one (used in CI)
	$(CONDA_ACTIVATE) poetry run isort --diff --check-only --settings-path pyproject.toml ./my_package/
	$(CONDA_ACTIVATE) poetry run black --diff --check --config pyproject.toml ./my_package/

.PHONY: types
types: # Check types annotation. Makes sure that they are consistent and all objects are covered.
	$(CONDA_ACTIVATE) poetry run pyright
	$(CONDA_ACTIVATE) poetry run mypy --config-file pyproject.toml ./my_package/

.PHONY: test
test: # Run unit tests.
	$(CONDA_ACTIVATE) poetry run pytest -c pyproject.toml --cov-report=html --cov=my_package ./my_package/*

.PHONY: check-safety
check-safety:
	$(CONDA_ACTIVATE) poetry check
	$(CONDA_ACTIVATE) poetry run safety check --full-report
	$(CONDA_ACTIVATE) poetry run bandit -ll --recursive robohive tests

.PHONY: check-all
check-all: check-codestyle types check-safety test

#* Cleaning
.PHONY: pycache-remove
pycache-remove:
	find . | grep -E "(__pycache__|\.pyc|\.pyo$$)" | xargs rm -rf

.PHONY: mypycache-remove
mypycache-remove:
	find . | grep -E ".mypy_cache" | xargs rm -rf

.PHONY: ipynbcheckpoints-remove
ipynbcheckpoints-remove:
	find . | grep -E ".ipynb_checkpoints" | xargs rm -rf

.PHONY: pytestcache-remove
pytestcache-remove:
	find . | grep -E ".pytest_cache" | xargs rm -rf

.PHONY: cleanup
cleanup: pycache-remove mypycache-remove ipynbcheckpoints-remove pytestcache-remove
