
/*
    mart_ipynb__function_questions.sql

    Stack Overflow questions matched to popular notebook function references via tags.
*/

WITH

questions AS (
  SELECT
    tags,
    tags_list,
    title,
    body AS question,
    accepted_answer,
    question_url,
    answer_url,
    answer_count,
    favorite_count,
    view_count
  FROM {{ ref('mart_stackoverflow__python_questions') }}
  ORDER BY view_count DESC
  LIMIT 100000
),

functions AS (
  SELECT
    f.function,
    CASE
      WHEN f.function LIKE '%np.%' THEN 'numpy'
      WHEN f.function LIKE '%pd.%' THEN 'pandas'
      WHEN f.function LIKE '%df.%' THEN 'dataframe'
      WHEN f.function LIKE '%tf.%' THEN 'tensorflow'
      WHEN f.function LIKE 'time.%' THEN 'time'
      WHEN f.function LIKE '%dt.%' THEN 'datetime'
      WHEN f.function LIKE '%plt.%' THEN 'matplotlib'
      WHEN f.function LIKE '%plot.%' THEN 'matplotlib'
      WHEN f.function LIKE '%random.%' THEN 'random'
      WHEN f.function LIKE '%re.%' THEN 'regex'
      WHEN f.function LIKE '%sys.%' THEN 'sys'
      WHEN f.function LIKE '%os.%' THEN 'os'
      ELSE NULL
    END AS function_parent,
    REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                ARRAY_REVERSE(SPLIT(f.function, '.'))[OFFSET(0)],
                'zeros',
                'zero'
              ),
              'float',
              'floating-point'
            ),
            '__init__',
            'init'
          ),
          'array',
          'numpy-ndarray'
        ),
        'str',
        'string'
      ),
      'print',
      'printing'
    ) AS function_child,
    references,
    repos,
    files,
    SAFE_DIVIDE(references, files) AS references_file,
    SAFE_DIVIDE(references, repos) AS references_repo,
    pct_referenes,
    pct_repos,
    pct_files
  FROM {{ ref('mart_ipynb__functions') }} AS f
  WHERE LENGTH(f.function) > 2
  ORDER BY files DESC
  LIMIT 2000
)

SELECT
  f.*,
  q.*
FROM functions AS f
JOIN questions AS q
  ON f.function_child IN UNNEST(SPLIT(q.tags, '|'))
  AND (
    f.function_parent IN UNNEST(SPLIT(q.tags, '|'))
    OR f.function_parent IS NULL
  )
ORDER BY view_count DESC
