
/*
    stg_github_repos__contents.sql

    Pulls all Github file contents from BigQuery public data.

    WARNING: This is a massive query; use with caution.

*/

SELECT
  f.*,
  c.content,
  c.copies
FROM
  {{ source('github_repos', 'contents') }} c
JOIN
  {{ ref('stg_github_repos__python_files') }} f
USING
  (id)
WHERE
  c.content IS NOT NULL
