
/*
    mart_stackoverflow__python_questions.sql

    Python-tagged Stack Overflow questions with accepted answers and URLs.
*/

SELECT
  *
FROM
  {{ ref('stg_stackoverflow__python_questions') }}
