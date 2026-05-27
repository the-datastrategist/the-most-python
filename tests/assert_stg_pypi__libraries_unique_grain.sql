-- Fails when more than one row exists for the same project-version pair.
select
    project,
    version,
    count(*) as row_count
from {{ ref('stg_pypi__libraries') }}
group by 1, 2
having count(*) > 1
