
/*
    mart_ipynb__libraries.sql

    Python libraries referenced in Jupyter notebooks with repo and file share metrics.
*/

WITH

repo_libraries AS (
  SELECT
    repo_name,
    repo_path,
    library
  FROM {{ ref('int_ipynb__notebook_cell_contents') }},
  UNNEST(libraries_from) AS library

  UNION DISTINCT

  SELECT
    repo_name,
    repo_path,
    library
  FROM {{ ref('int_ipynb__notebook_cell_contents') }},
  UNNEST(libraries_import) AS library
),

totals AS (
  SELECT
    APPROX_COUNT_DISTINCT(repo_name) AS repos_total,
    APPROX_COUNT_DISTINCT(repo_path) AS files_total
  FROM repo_libraries
),

library_agg AS (
  SELECT
    library,
    APPROX_COUNT_DISTINCT(repo_name) AS repos,
    APPROX_COUNT_DISTINCT(repo_path) AS files
  FROM repo_libraries
  GROUP BY 1
)

SELECT
  *,
  SAFE_DIVIDE(files, repos) AS files_repo,
  SAFE_DIVIDE(repos, repos_total) AS pct_repos,
  SAFE_DIVIDE(files, files_total) AS pct_files
FROM library_agg AS a
JOIN totals
  ON 1 = 1
ORDER BY files DESC
