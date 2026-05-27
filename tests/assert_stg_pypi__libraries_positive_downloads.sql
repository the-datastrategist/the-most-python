select
    project,
    version,
    downloads
from {{ ref('stg_pypi__libraries') }}
where downloads is null
    or downloads < 1
