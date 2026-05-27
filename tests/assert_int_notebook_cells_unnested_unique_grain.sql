select
    repo_name,
    repo_path,
    count(*) as row_count
from {{ ref('int_notebook_cells_unnested') }}
group by 1, 2
having count(*) > 1
