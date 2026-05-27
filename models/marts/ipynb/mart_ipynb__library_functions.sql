
/*
    mart_ipynb__library_functions.sql

    Co-occurrence of Python libraries and functions within the same notebook file.
    A function may not belong to the library it is paired with.
*/

WITH

repo_functions AS (
  SELECT
    repo_name,
    repo_path,
    function
  FROM (
    SELECT
      repo_name,
      repo_path,
      REGEXP_EXTRACT(function_ud, r'def ([A-Za-z0-9_]+)') AS function_ud,
      REGEXP_REPLACE(function, r'(^\.|\()', '') AS function
    FROM {{ ref('int_ipynb__notebook_cell_contents') }} AS c,
    UNNEST(c.functions_ud) AS function_ud,
    UNNEST(c.functions) AS function
  )
  WHERE function != function_ud
),

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

repo_library_functions AS (
  SELECT
    repo_name,
    repo_path,
    library,
    function
  FROM repo_libraries AS l
  JOIN repo_functions AS f
    USING (repo_name, repo_path)
),

library_functions_agg AS (
  SELECT
    library,
    function,
    SUM(1) AS references,
    APPROX_COUNT_DISTINCT(repo_name) AS repos,
    APPROX_COUNT_DISTINCT(repo_path) AS files
  FROM repo_library_functions
  GROUP BY 1, 2
),

totals AS (
  SELECT
    SUM(1) AS references_total,
    APPROX_COUNT_DISTINCT(repo_name) AS repos_total,
    APPROX_COUNT_DISTINCT(repo_path) AS files_total
  FROM repo_library_functions
)

SELECT
  *,
  SAFE_DIVIDE(references, references_total) AS pct_references,
  SAFE_DIVIDE(repos, repos_total) AS pct_repos,
  SAFE_DIVIDE(files, files_total) AS pct_files
FROM library_functions_agg
JOIN totals
  ON 1 = 1
