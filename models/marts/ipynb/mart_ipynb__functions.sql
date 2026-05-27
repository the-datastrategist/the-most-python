
/*
    mart_ipynb__functions.sql

    Python function references across Jupyter notebooks with popularity metrics.
*/

WITH

repo_functions AS (
  SELECT
    repo_name,
    repo_path,
    REGEXP_EXTRACT(function_ud, r'def ([A-Za-z0-9_]+)') AS function_ud,
    REPLACE(function, '(', '') AS function
  FROM {{ ref('int_ipynb__notebook_cell_contents') }} AS c,
  UNNEST(c.functions_ud) AS function_ud,
  UNNEST(c.functions) AS function
),

totals AS (
  SELECT
    SUM(1) AS references_total,
    APPROX_COUNT_DISTINCT(repo_name) AS repos_total,
    APPROX_COUNT_DISTINCT(repo_path) AS files_total
  FROM repo_functions
  WHERE function_ud != function
),

function_agg AS (
  SELECT
    REGEXP_REPLACE(function, r'^\.', '') AS function,
    SUM(1) AS references,
    APPROX_COUNT_DISTINCT(repo_path) AS files,
    APPROX_COUNT_DISTINCT(repo_name) AS repos
  FROM repo_functions
  WHERE function_ud != function
  GROUP BY 1
  ORDER BY 2 DESC
)

SELECT
  f.*,
  t.*,
  SAFE_DIVIDE(f.references, f.files) AS referenes_file,
  SAFE_DIVIDE(f.references, f.repos) AS referenes_repo,
  SAFE_DIVIDE(f.references, t.references_total) AS pct_referenes,
  SAFE_DIVIDE(f.repos, t.repos_total) AS pct_repos,
  SAFE_DIVIDE(f.files, t.files_total) AS pct_files
FROM function_agg AS f
JOIN totals AS t
  ON 1 = 1
ORDER BY references DESC
