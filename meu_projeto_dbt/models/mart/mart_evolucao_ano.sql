{{ config(materialized='table') }}

with dados as (
    select * from {{ ref('int_gestor_completo') }}
),

gestores_2019 as (
    select co_escola, min(id_gestor) as id_gestor
    from dados
    where nu_ano_censo = 2019
    group by co_escola
),

gestores_2020 as (
    select co_escola, min(id_gestor) as id_gestor
    from dados
    where nu_ano_censo = 2020
    group by co_escola
),

comparacao as (
    select
        g19.co_escola,
        g19.id_gestor as gestor_2019,
        g20.id_gestor as gestor_2020,
        case
            when g19.id_gestor != g20.id_gestor then 1
            else 0
        end as houve_troca
    from gestores_2019 g19
    join gestores_2020 g20 using (co_escola)
)

select * from comparacao
