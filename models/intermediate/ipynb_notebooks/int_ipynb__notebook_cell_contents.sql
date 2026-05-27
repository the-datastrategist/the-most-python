
/*
    int_ipynb__notebook_cell_contents.sql

    Per-notebook arrays of import/from libraries and function references
    parsed from code cells. Downstream marts aggregate these to library and
    function popularity metrics.
*/

WITH

code_cells AS (
  SELECT
    c.repo_name,
    c.repo_path,
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        COALESCE(cell.cell_source, cell.cell_input),
        r'\\n\"\,\s+\"',
        '\n'
      ),
      r'^"|"$|",$|^\[\s+"|\],$',
      ''
    ) AS cell_code
  FROM {{ ref('int_notebook_cells_unnested') }} AS c,
  UNNEST(c.cells) AS cell
  WHERE cell.cell_type = 'code'
),

per_cell AS (
  SELECT
    repo_name,
    repo_path,
    REGEXP_EXTRACT_ALL(cell_code, r'(?m)^from\s+([A-Za-z_][\w\.]*)') AS libraries_from,
    REGEXP_EXTRACT_ALL(cell_code, r'(?m)^import\s+([A-Za-z_][\w\.]*)') AS libraries_import,
    REGEXP_EXTRACT_ALL(cell_code, r'def\s+[A-Za-z_][\w]*') AS functions_ud,
    REGEXP_EXTRACT_ALL(cell_code, r'[A-Za-z_][\w\.]*\(') AS functions
  FROM code_cells
  WHERE cell_code IS NOT NULL
    AND cell_code != ''
)

SELECT
  repo_name,
  repo_path,
  ARRAY(
    SELECT DISTINCT lib
    FROM UNNEST(ARRAY_CONCAT_AGG(IFNULL(libraries_from, []))) AS lib
    WHERE lib IS NOT NULL
      AND lib != ''
  ) AS libraries_from,
  ARRAY(
    SELECT DISTINCT lib
    FROM UNNEST(ARRAY_CONCAT_AGG(IFNULL(libraries_import, []))) AS lib
    WHERE lib IS NOT NULL
      AND lib != ''
  ) AS libraries_import,
  ARRAY(
    SELECT DISTINCT fn
    FROM UNNEST(ARRAY_CONCAT_AGG(IFNULL(functions_ud, []))) AS fn
    WHERE fn IS NOT NULL
      AND fn != ''
  ) AS functions_ud,
  ARRAY(
    SELECT DISTINCT fn
    FROM UNNEST(ARRAY_CONCAT_AGG(IFNULL(functions, []))) AS fn
    WHERE fn IS NOT NULL
      AND fn != ''
  ) AS functions
FROM per_cell
GROUP BY 1, 2
