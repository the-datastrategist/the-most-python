
/*
    mart_stackoverflow__python_tags.sql

    Aggregate engagement metrics by question tag set.
*/

SELECT
  *
FROM
  {{ ref('int_stackoverflow_tags_aggregated_metrics') }}
