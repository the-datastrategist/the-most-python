select
    parsed.repo_name,
    parsed.repo_path
from {{ ref('int_ipynb__notebook_cell_contents') }} as parsed
left join {{ ref('int_notebook_cells_unnested') }} as notebooks
    using (repo_name, repo_path)
where notebooks.repo_name is null
