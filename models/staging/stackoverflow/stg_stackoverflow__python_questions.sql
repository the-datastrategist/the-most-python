-- Collect all StackOverflow questions related to Python

SELECT
  q.id,
  q.tags,
  REPLACE(q.tags, '|', ', ') as tags_list,
  q.title,
  q.body,
  q.accepted_answer_id,
  a.body AS accepted_answer,
  CONCAT('https://stackoverflow.com/questions/', q.id) AS question_url,
  CONCAT('https://stackoverflow.com/a/', q.accepted_answer_id) AS answer_url,
  IF(q.accepted_answer_id IS NULL, FALSE, TRUE) AS has_accepted_answer,
  IF(q.community_owned_date IS NULL, FALSE, TRUE) AS is_community_owned,
  q.answer_count,
  q.comment_count,
  q.favorite_count,
  q.view_count,
  DATE(q.creation_date) AS creation_date,
  DATE(q.last_activity_date) AS last_activity_date,
  DATE(q.last_edit_date) AS last_edit_date,
  DATE(q.community_owned_date) AS community_owned_date,

FROM
  {{ source('stackoverflow', 'posts_questions') }} q
LEFT JOIN
  {{ source('stackoverflow', 'posts_answers') }} a
ON
  q.accepted_answer_id = a.id
WHERE
  q.tags LIKE '%python%'
