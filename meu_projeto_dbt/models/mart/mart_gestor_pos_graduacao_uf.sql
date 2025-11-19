{{ config(materialized='table') }}

with gestores_municipio as (
    select
        nu_ano_censo,
        uf_desc,
        total_especializacao,
        total_mestrado,
        total_doutorado,
        total_pos_nenhum
    from {{ ref('int_gestor_pos_graduacao_municipio') }}
)

select
    nu_ano_censo,
    uf_desc,
    sum(total_especializacao) as total_especializacao,
    sum(total_mestrado) as total_mestrado,
    sum(total_doutorado) as total_doutorado,
    sum(total_pos_nenhum) as total_pos_nenhum
from gestores_municipio
group by 1, 2
order by 1, 2
