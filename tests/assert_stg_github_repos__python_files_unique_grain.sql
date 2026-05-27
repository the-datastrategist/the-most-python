select
    id,
    repo_name,
    repo_ref,
    repo_path,
    count(*) as row_count
from {{ ref('stg_github_repos__python_files') }}
group by 1, 2, 3, 4
having count(*) > 1
