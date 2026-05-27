# The Most Python: How Data Scientists Use Python in the Wild

**The Most Python** is a production-style analytics pipeline that analyzes how data scientists use Python in practice, using large-scale public data from **GitHub**, **Stack Overflow**, and **PyPI**.

The project extracts, normalizes, and models real usage patterns of:

- Python libraries
- Functions and APIs
- Notebook code cells
- Common questions and pain points

The goal is to move beyond surveys and tutorials and answer:

> *How do data scientists actually use Python when solving real problems?*

This repository demonstrates applied data engineering and analytics modeling at warehouse scale with **dbt + BigQuery**.

## Key deliverables

- [Project Brief](https://thedatastrategist.notion.site/The-Most-Used-Python-61218fdc12564fcc8bef195098920808)
- [Looker: "The Most Python" Report](https://datastudio.google.com/reporting/a5096f7e-26c8-48f7-a496-da1fdef6b008)
- [Medium: The Top 10 Python Functions Used by Data Scientists](https://thedatastrategist.medium.com/what-are-pythons-most-used-functions-d760dc28fd96)
- [LinkedIn: The Top 10 Python Functions Used by Data Scientists](https://www.linkedin.com/feed/update/urn:li:activity:6968311247918235648/)

## Pipeline architecture

Models follow a **staging → intermediate → marts** layout:

| Layer | Purpose | Materialization |
|-------|---------|-----------------|
| **Staging** (`stg_*`) | Clean, filter, and join raw public datasets | Views (tables for heavy GitHub/Stack Overflow/PyPI builds) |
| **Intermediate** (`int_*`) | Reusable parsing and rollups (notebook cells, tag metrics) | Tables |
| **Marts** (`mart_*`) | Analytics-ready datasets for reporting and exploration | Tables |

```mermaid
flowchart LR
  subgraph sources [BigQuery public data]
    GH[github_repos]
    SO[stackoverflow]
    PY[pypi]
  end

  subgraph staging [Staging]
    PF[stg_github_repos__python_files]
    PC[stg_github_repos__contents]
    PFC[stg_github_repos__python_file_contents]
    SQ[stg_stackoverflow__python_questions]
    PL[stg_pypi__libraries]
  end

  subgraph intermediate [Intermediate]
    NC[int_notebook_cells_unnested]
    CC[int_ipynb__notebook_cell_contents]
    TA[int_stackoverflow_tags_aggregated_metrics]
  end

  subgraph marts [Marts]
    MNC[mart_ipynb__notebook_cells]
    MFN[mart_ipynb__functions]
    MSQ[mart_stackoverflow__python_questions]
  end

  GH --> PF --> PC --> PFC --> NC --> CC
  NC --> MNC --> MFN
  SO --> SQ --> MSQ --> TA
  PY --> PL
```

Raw tables are declared in `models/staging/_sources.yml` and referenced with `{{ source() }}`. Downstream models use `{{ ref() }}` only—no hardcoded project/dataset names.

## Data sources

### GitHub (`bigquery-public-data.github_repos`)

- Public Python repositories and Jupyter notebooks (`.ipynb`)
- File metadata joined to contents for notebook and script analysis

### Stack Overflow (`bigquery-public-data.stackoverflow`)

- Python-tagged questions with accepted answers and engagement metrics

### PyPI (`bigquery-public-data.pypi`)

- Download counts (sampled to June 2022) joined to package metadata

All data is from **BigQuery public datasets** and transformed in a reproducible, SQL-first workflow.

## Warehouse models

| Model | Description |
|-------|-------------|
| `stg_github_repos__python_files` | Python `.py` and `.ipynb` paths on `master` |
| `stg_github_repos__contents` | File metadata + non-null contents |
| `stg_github_repos__python_file_contents` | Materialized contents for downstream parsing (**very large**) |
| `stg_stackoverflow__python_questions` | Python-tagged questions with answer text and URLs |
| `stg_pypi__libraries` | PyPI downloads + metadata (June 2022 window) |
| `int_notebook_cells_unnested` | Parsed notebook cells per repo path |
| `int_ipynb__notebook_cell_contents` | Per-notebook import and function reference arrays |
| `int_stackoverflow_tags_aggregated_metrics` | Tag-set aggregates and accepted-answer rates |
| `mart_ipynb__functions` | Function popularity across notebooks |
| `mart_ipynb__libraries` | Library usage across notebooks |
| `mart_stackoverflow__python_questions` | Python SO questions (mart exposure of staging) |
| `mart_stackoverflow__python_tags` | Tag-level engagement metrics |

See `models/marts/_marts__models.yml` for the full mart catalog. Column-level documentation and tests live alongside models in `_models.yml` files.

## Local development

### Prerequisites

- Docker (recommended), or Python 3.11+ with `dbt-bigquery`
- A GCP project with BigQuery enabled
- A service account JSON key with BigQuery job/data access

### Environment variables

| Variable | Description |
|----------|-------------|
| `DBT_BQ_PROJECT` | GCP project id where models are built |
| `DBT_BQ_DATASET` | BigQuery dataset (default: `the_most_python`) |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to service account key JSON |

### Docker (recommended)

```bash
docker build -t the-most-python-dbt .

# Validate project parses and compiles (no warehouse run)
docker run --rm \
  -e DBT_BQ_PROJECT=your-gcp-project \
  -e DBT_BQ_DATASET=the_most_python \
  -v /path/to/key.json:/secrets/gcp-key.json:ro \
  the-most-python-dbt parse

docker run --rm \
  -e DBT_BQ_PROJECT=your-gcp-project \
  -e DBT_BQ_DATASET=the_most_python \
  -v /path/to/key.json:/secrets/gcp-key.json:ro \
  the-most-python-dbt compile

# Run the DAG (costly on full GitHub contents — use --select)
docker run --rm \
  -e DBT_BQ_PROJECT=your-gcp-project \
  -v /path/to/key.json:/secrets/gcp-key.json:ro \
  the-most-python-dbt build --select stg_stackoverflow__python_questions+
```

Profiles are in `profiles/profiles.yml` (`DBT_PROFILES_DIR` is set in the image).

### Cost notes

- `stg_github_repos__python_file_contents` scans multi-TB GitHub content data; materialize intentionally and use `--select` during development.
- `stg_pypi__libraries` limits downloads to **2022-06-01** through **2022-06-30** to keep query size manageable.

Analytical models live under `models/marts/`; build with `dbt build --select marts+` or narrower `--select` paths during development.
