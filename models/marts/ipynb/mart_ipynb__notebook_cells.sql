
/*
    mart_ipynb__notebook_cells.sql

    Parsed Jupyter notebook cells (type, source, execution metadata) per repo path.
*/

SELECT
  *
FROM
  {{ ref('int_notebook_cells_unnested') }}
