# dbt via Docker — see README for prerequisites (.env, GCP key, docker build).
DOCKER_IMAGE ?= the-most-python-dbt
ENV_FILE ?= .env
DBT_CMD ?= build

ifneq (,$(wildcard $(ENV_FILE)))
  include $(ENV_FILE)
  export
endif

GCP_KEY_PATH ?= $(GOOGLE_APPLICATION_CREDENTIALS)

# Host repo mounted so model changes apply without rebuilding the image.
DOCKER_OPTS := --rm \
	-v "$(CURDIR):/app" \
	-v "$(GCP_KEY_PATH):/secrets/gcp-key.json:ro" \
	-w /app \
	-e GOOGLE_APPLICATION_CREDENTIALS=/secrets/gcp-key.json

ifneq (,$(wildcard $(ENV_FILE)))
  DOCKER_OPTS += --env-file $(ENV_FILE)
endif

DOCKER_RUN = docker run $(DOCKER_OPTS) $(DOCKER_IMAGE)

# Normalize DIR to a path under models/ (e.g. staging/pypi -> models/staging/pypi).
define normalize_dbt_dir
$(if $(findstring models/,$(1)),$(1),models/$(1))
endef

# Default test selection: core models and singular tests, excluding GitHub table scans.
DBT_TEST_SELECT ?= \
	stg_stackoverflow__python_questions \
	stg_pypi__libraries \
	int_stackoverflow_tags_aggregated_metrics \
	int_notebook_cells_unnested \
	int_ipynb__notebook_cell_contents \
	mart_stackoverflow__python_questions \
	mart_stackoverflow__python_tags \
	mart_pypi__libraries \
	mart_ipynb__notebook_cells \
	mart_ipynb__functions \
	mart_ipynb__libraries \
	assert_stg_pypi__libraries_unique_grain \
	assert_stg_pypi__libraries_positive_downloads \
	assert_int_stackoverflow_tags_metrics_valid \
	assert_int_notebook_cells_unnested_unique_grain \
	assert_int_ipynb__notebook_cell_contents_unique_grain \
	assert_int_ipynb__notebook_cell_contents_references_notebooks

.PHONY: help docker-build run-model run-dir test test-all

help:
	@echo "Usage:"
	@echo "  make docker-build"
	@echo "  make run-model MODEL=<model_name>"
	@echo "  make run-dir     DIR=<path_under_models>"
	@echo "  make test        # data tests (default selection; no GitHub scans)"
	@echo "  make test-all    # all data tests, including GitHub"
	@echo ""
	@echo "Examples:"
	@echo "  make run-model MODEL=stg_stackoverflow__python_questions"
	@echo "  make run-dir     DIR=staging/stackoverflow"
	@echo "  make run-dir     DIR=models/marts"
	@echo "  make test"
	@echo ""
	@echo "Optional: DBT_CMD=run (default: build), ENV_FILE=.env"

docker-build:
	docker build -t $(DOCKER_IMAGE) .

run-model:
	@test -n "$(MODEL)" || (echo "ERROR: MODEL is required. Example: make run-model MODEL=stg_pypi__libraries" && exit 1)
	@test -n "$(GCP_KEY_PATH)" || (echo "ERROR: set GOOGLE_APPLICATION_CREDENTIALS in $(ENV_FILE) or export it" && exit 1)
	@test -f "$(GCP_KEY_PATH)" || (echo "ERROR: GCP key not found: $(GCP_KEY_PATH)" && exit 1)
	$(DOCKER_RUN) $(DBT_CMD) --select $(MODEL)

run-dir:
	@test -n "$(DIR)" || (echo "ERROR: DIR is required. Example: make run-dir DIR=staging/github_repos" && exit 1)
	@test -n "$(GCP_KEY_PATH)" || (echo "ERROR: set GOOGLE_APPLICATION_CREDENTIALS in $(ENV_FILE) or export it" && exit 1)
	@test -f "$(GCP_KEY_PATH)" || (echo "ERROR: GCP key not found: $(GCP_KEY_PATH)" && exit 1)
	$(DOCKER_RUN) $(DBT_CMD) --select path:$(call normalize_dbt_dir,$(DIR))

test:
	@test -n "$(GCP_KEY_PATH)" || (echo "ERROR: set GOOGLE_APPLICATION_CREDENTIALS in $(ENV_FILE) or export it" && exit 1)
	@test -f "$(GCP_KEY_PATH)" || (echo "ERROR: GCP key not found: $(GCP_KEY_PATH)" && exit 1)
	$(DOCKER_RUN) test --select $(DBT_TEST_SELECT)

test-all:
	@test -n "$(GCP_KEY_PATH)" || (echo "ERROR: set GOOGLE_APPLICATION_CREDENTIALS in $(ENV_FILE) or export it" && exit 1)
	@test -f "$(GCP_KEY_PATH)" || (echo "ERROR: GCP key not found: $(GCP_KEY_PATH)" && exit 1)
	$(DOCKER_RUN) test
