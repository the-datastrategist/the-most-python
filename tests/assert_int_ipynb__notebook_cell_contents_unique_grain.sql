select
    repo_name,
    repo_path,
    count(*) as row_count
from {{ ref('int_ipynb__notebook_cell_contents') }}
group by 1, 2
having count(*) > 1
