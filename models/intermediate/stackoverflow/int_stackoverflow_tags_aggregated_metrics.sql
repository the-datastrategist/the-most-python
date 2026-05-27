-- Aggregate metrics for StackOverflow tags related to Python

with

tag_agg as (
  SELECT  
  tags,
  tags_list,
  sum(1) as questions,
  sum(if(accepted_answer_id is not null, 1, 0)) as accepted_answers,
  sum(answer_count) as answer_count,
  sum(comment_count) as comment_count,
  sum(favorite_count) as favorite_count,
  sum(view_count) as view_count,
  avg(answer_count) as avg_answer_count,
  avg(comment_count) as avg_comment_count,
  avg(favorite_count) as avg_favorite_count,
  avg(view_count) as avg_view_count
  FROM {{ ref('stg_stackoverflow__python_questions') }}
  GROUP BY 1, 2
)


select
*,
SAFE_DIVIDE(accepted_answers, questions) AS pct_w_accepted_answer,
SAFE_DIVIDE(questions, SUM(questions) over()) AS pct_questions,
from tag_agg
