
/*
    mart_ipynb__function_samples.sql

    Ranked notebook code samples for high-usage Python functions.
*/

WITH

top_repo_code AS (
  SELECT DISTINCT
    repo_path,
    repos,
    repo_rank,
    repo_prank,
    cell_code,
    LENGTH(cell_code) AS code_length
  FROM {{ ref('mart_ipynb__notebook_code') }}
  WHERE repo_prank >= 0.999
    AND cell_code NOT LIKE '%SECRET%'
    AND cell_code NOT LIKE '%KEY%'
    AND LENGTH(cell_code) >= 50
    AND repo_path NOT LIKE '%Untitled%ipynb'
    AND repo_path NOT IN (
      'index.ipynb',
      'test.ipynb',
      'demo.ipynb'
    )
),

top_functions AS (
  SELECT
    function,
    CONCAT(function, r'\(') AS function_regex,
    referenes_file,
    referenes_repo,
    pct_referenes,
    pct_repos,
    pct_files
  FROM {{ ref('mart_ipynb__functions') }}
  WHERE pct_files > 0.005
    AND LENGTH(function) > 2
),

function_code AS (
  SELECT
    *,
    SUM(1) OVER (PARTITION BY repo_path) AS n_paths,
    SUM(1) OVER (PARTITION BY cell_code) AS n_cells
  FROM top_repo_code AS trc
  JOIN top_functions AS f
    ON REGEXP_CONTAINS(cell_code, function_regex)
)

SELECT
  *
FROM (
  SELECT
    *,
    (repos_rank / 2 + length_rank + paths_rank + cells_rank) / 4 AS avg_rank,
    RANK() OVER (
      PARTITION BY function
      ORDER BY (repos_rank / 2 + length_rank + paths_rank + cells_rank)
    ) AS composite_rank,
    RANK() OVER (
      PARTITION BY function, repo_path
      ORDER BY (repos_rank / 2 + length_rank + paths_rank + cells_rank)
    ) AS dupe_path_rank
  FROM (
    SELECT
      *,
      RANK() OVER (PARTITION BY function ORDER BY repos DESC) AS repos_rank,
      RANK() OVER (PARTITION BY function ORDER BY code_length) AS length_rank,
      RANK() OVER (PARTITION BY function ORDER BY n_paths) AS paths_rank,
      RANK() OVER (PARTITION BY function ORDER BY n_cells) AS cells_rank
    FROM function_code
  )
)
