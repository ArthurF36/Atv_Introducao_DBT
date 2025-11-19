{{ config(materialized='table') }}

with dados as (
    select * from {{ ref('int_gestor_completo') }}
),

agregado as (
    select
        nu_ano_censo,
        count(distinct id_gestor) as total_gestores,
        count(distinct co_escola) as total_escolas,

        count(*) filter (where possui_deficiencia = 'Sim') as total_com_deficiencia,
        count(*) filter (where possui_licenciatura = 'Sim') as total_com_licenciatura,
        count(*) filter (where possui_mestrado = 'Sim') as total_com_mestrado,
        count(*) filter (where possui_doutorado = 'Sim') as total_com_doutorado,
        count(*) filter (where cargo_desc = 'Diretor') as total_diretores,

        round(avg(idade_estimada), 1) as idade_media,

        count(*) filter (where sexo_desc = 'Feminino') * 1.0 / count(*) as pct_feminino,
        count(*) filter (where sexo_desc = 'Masculino') * 1.0 / count(*) as pct_masculino
    from dados
    group by nu_ano_censo
)

select * from agregado
