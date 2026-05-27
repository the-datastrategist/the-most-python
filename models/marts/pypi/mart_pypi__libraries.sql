
/*
    mart_pypi__libraries.sql

    PyPI download counts joined to package metadata (June 2022 window).
*/

SELECT
  *
FROM
  {{ ref('stg_pypi__libraries') }}
