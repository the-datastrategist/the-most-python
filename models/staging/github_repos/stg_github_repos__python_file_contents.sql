-- Collect all Python files from Github
-- WARNING: This is a 2.7TB query

/*
    stg_github_repos__python_file_contents.sql

    Get the file contents (ie code and text) from all
    Github repos.

    WARNING:
        This is a 2.7TB query. We have materialized this
        as a table because referencing as a view would become
        cost inefficient.
*/

SELECT
  *
FROM
  {{ ref('stg_github_repos__contents') }}
