# The Most Python: How Data Scientists Use Python in the Wild

**The Most Python** is an end-to-end analytics pipeline that analyzes how data scientists use Python in practice, based on large-scale, publicly available data from **GitHub** and **Stack Overflow**.

The project extracts, normalizes, and models real usage patterns of:
- Python libraries
- Functions and APIs
- Notebook code cells
- Common questions and pain points

The goal is to move beyond surveys and tutorials, and instead answer:
> *How do data scientists actually use Python when solving real problems?*

This repository demonstrates applied data engineering, analytics modeling, and analytical thinking at production scale using **dbt + SQL**.

## Key Deliverables
- [Project Brief](https://thedatastrategist.notion.site/The-Most-Used-Python-61218fdc12564fcc8bef195098920808)
- [Looker: "The Most Python" Report](https://datastudio.google.com/reporting/a5096f7e-26c8-48f7-a496-da1fdef6b008)
- [Medium: The Top 10 Python Functions Used by Data Scientists](https://thedatastrategist.medium.com/what-are-pythons-most-used-functions-d760dc28fd96)
- [LinkedIn: The Top 10 Python Functions Used by Data Scientists](https://www.linkedin.com/feed/update/urn:li:activity:6968311247918235648/)

<br>

## Data Sources

### GitHub
- Public Python repositories
- Jupyter notebooks (`.ipynb`)
- Parsed notebook cells, imports, function calls, and code blocks

### Stack Overflow
- Python-tagged questions
- Question text, tags, and metadata
- Aggregated usage and topic trends

All data is sourced from **public datasets** and processed in a reproducible, SQL-first workflow.

<br>

## Analytical Focus Areas

The pipeline supports analysis across multiple dimensions:

### 1. Library Usage
- Most frequently imported Python libraries
- Co-occurrence patterns between libraries
- Differences between notebook-centric vs script-centric usage

### 2. Function & API Usage
- Most commonly called Python functions
- Library-specific function popularity
- Core language vs third-party API usage

### 3. Notebook Behavior
- Code cell structure and length
- Function density per notebook
- Common code patterns in exploratory workflows

### 4. Developer Questions & Pain Points
- Most common Python questions on Stack Overflow
- Tag-level topic clustering
- Mapping questions → libraries → functions

<br>

## Project Architecture

This project is implemented as a **dbt analytics engineering pipeline**, emphasizing:
- Modular SQL models
- Clear separation of staging, intermediate, and analytical layers
- Reproducible transformations
- Warehouse-native scalability

<br>

## Tables

This project’s dbt models generate the following warehouse relations:

- **`stg_github_repos__python_file_contents` (table)**: Python + notebook file metadata joined to full file contents from the GitHub public dataset.
- **`stg_stackoverflow__python_questions` (table)**: Stack Overflow questions tagged with Python, enriched with accepted answer text + URLs and engagement metrics.
- **`stg_pypi__libraries` (table)**: PyPI packages with download counts (sampled window) joined to distribution metadata (summary, author, links, keywords).
- **`int_notebook_cells_unnested`**: Parsed `.ipynb` JSON into per-notebook structured cell arrays (type, source/input, execution/output metadata).
- **`int_stackoverflow_tags_aggregated_metrics` (table)**: Aggregations by tag set (question volume, engagement totals/averages, % with accepted answer).

- **`my_first_dbt_model` (table)** / **`my_second_dbt_model`**: Starter/example models included from the dbt template.

