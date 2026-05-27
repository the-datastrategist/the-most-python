select
    tags,
    tags_list,
    questions,
    accepted_answers,
    pct_w_accepted_answer
from {{ ref('int_stackoverflow_tags_aggregated_metrics') }}
where questions is null
    or questions < 1
    or accepted_answers < 0
    or accepted_answers > questions
    or pct_w_accepted_answer < 0
    or pct_w_accepted_answer > 1
