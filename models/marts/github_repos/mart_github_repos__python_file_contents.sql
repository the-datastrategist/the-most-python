
/*
    mart_github_repos__python_file_contents.sql

    GitHub Python and notebook file contents for downstream parsing.

    WARNING: Large table — built from stg_github_repos__python_file_contents.
*/

SELECT
  *
FROM
  {{ ref('stg_github_repos__python_file_contents') }}
