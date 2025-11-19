{{ config(materialized='view') }}

with gestores as (
    select
        nu_ano_censo,
        uf_desc,
        co_municipio,
        in_especializacao,
        in_mestrado,
        in_doutorado,
        in_pos_nenhum
    from {{ ref('int_gestor_completo') }}
)

select
    nu_ano_censo,
    uf_desc,
    co_municipio,
    sum(in_especializacao) as total_especializacao,
    sum(in_mestrado) as total_mestrado,
    sum(in_doutorado) as total_doutorado,
    sum(in_pos_nenhum) as total_pos_nenhum
from gestores
group by 1, 2, 3
order by 1, 2, 3
