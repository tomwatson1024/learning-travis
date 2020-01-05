SHELL = /bin/bash -o pipefail
ALL_FILES = src test

.PHONY: ci
ci: lint coverage

.PHONY: lint
lint: flake8 pylint mypy docs_check isort_check black_check



.PHONY: flake8
flake8:
	poetry run flake8 $(ALL_FILES)

.PHONY: pylint
pylint:
	poetry run pylint $(ALL_FILES)

.PHONY: mypy
mypy:
	poetry run mypy $(ALL_FILES) --warn-unused-ignores

BLACK_COMMAND := poetry run black $(ALL_FILES)

.PHONY: black_check
black_check:
	$(BLACK_COMMAND) --check

.PHONY: black
black:
	$(BLACK_COMMAND)

ISORT_COMMAND := poetry run isort --recursive $(ALL_FILES)

.PHONY: isort_check
isort_check:
	$(ISORT_COMMAND) --check-only

.PHONY: isort
isort:
	$(ISORT_COMMAND)

.PHONY: docs_check
docs_check:
	poetry run pydocstyle $(ALL_FILES)


.PHONY: test
test:
	poetry run tox -v -e clean,py36,report -- $(EXTRA_PYTEST_ARGS)

.PHONY: coverage
coverage: test
	poetry run coverage report --fail-under=100 --skip-covered \
	--omit=$(shell cat .coverage_not_yet | grep -vE "^\s*(#.*)?$$" | tr "\n" ",") \
	| grep -v "TOTAL"
