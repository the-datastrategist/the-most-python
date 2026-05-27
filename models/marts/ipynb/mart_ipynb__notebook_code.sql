
/*
    mart_ipynb__notebook_code.sql

    Cleaned code cells per notebook path with repo breadth ranks.
*/

WITH

paths AS (
  SELECT
    *,
    RANK() OVER (ORDER BY repos DESC) AS repo_rank,
    PERCENT_RANK() OVER (ORDER BY repos) AS repo_prank
  FROM (
    SELECT
      repo_path,
      COUNT(DISTINCT repo_name) AS repos
    FROM {{ ref('mart_ipynb__notebook_cells') }}
    GROUP BY 1
  )
),

cell_code AS (
  SELECT DISTINCT
    repo_path,
    cell.cell AS cell,
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        COALESCE(cell.cell_source, cell.cell_input),
        r'\\n\"\,\s+\"',
        '\n'
      ),
      r'^"|"$|",$|^\[\s+"|\],$',
      ''
    ) AS cell_code
  FROM {{ ref('mart_ipynb__notebook_cells') }} AS c,
  UNNEST(c.cells) AS cell
  WHERE cell.cell_type = 'code'
)

SELECT
  c.*,
  p.* EXCEPT (repo_path)
FROM cell_code AS c
JOIN paths AS p
  USING (repo_path)
