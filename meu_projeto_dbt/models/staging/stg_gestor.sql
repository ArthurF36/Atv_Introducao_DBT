{{ config(materialized='view') }}

with gestor_2019 as (
    select
        cast("ID_GESTOR" as text) as id_gestor,
        "CO_ENTIDADE" as co_escola,
        "NU_ANO_CENSO" as nu_ano_censo,
        "TP_DEPENDENCIA" as tp_dependencia,
        "TP_SEXO" as tp_sexo,
        "TP_COR_RACA" as tp_cor_raca,
        "TP_ESCOLARIDADE" as tp_escolaridade,
        "TP_TIPO_ACESSO_CARGO" as tp_tipo_acesso_cargo,
        "TP_TIPO_CONTRATACAO" as tp_tipo_contratacao,
        "TP_CARGO_GESTOR" as tp_cargo_gestor,
        "IN_NECESSIDADE_ESPECIAL" as in_necessidade_especial,
        "IN_LICENCIATURA_1" as in_licenciatura_1,
        "IN_LICENCIATURA_2" as in_licenciatura_2,
        "IN_MESTRADO" as in_mestrado,
        "IN_DOUTORADO" as in_doutorado,
        "NU_IDADE" as nu_idade,
        "NU_IDADE_REFERENCIA" as nu_idade_referencia,
        "CO_UF" as co_uf,
        "CO_MUNICIPIO" as co_municipio,
        "IN_ESPECIALIZACAO" as in_especializacao,
        "IN_POS_NENHUM" as in_pos_nenhum
    from {{ source('raw', 'gestor_2019') }}
    where "TP_DEPENDENCIA" != 4
),

gestor_2020 as (
    select
        cast("ID_GESTOR" as text) as id_gestor,
        "CO_ENTIDADE" as co_escola,
        "NU_ANO_CENSO" as nu_ano_censo,
        "TP_DEPENDENCIA" as tp_dependencia,
        "TP_SEXO" as tp_sexo,
        "TP_COR_RACA" as tp_cor_raca,
        "TP_ESCOLARIDADE" as tp_escolaridade,
        "TP_TIPO_ACESSO_CARGO" as tp_tipo_acesso_cargo,
        "TP_TIPO_CONTRATACAO" as tp_tipo_contratacao,
        "TP_CARGO_GESTOR" as tp_cargo_gestor,
        "IN_NECESSIDADE_ESPECIAL" as in_necessidade_especial,
        "IN_LICENCIATURA_1" as in_licenciatura_1,
        "IN_LICENCIATURA_2" as in_licenciatura_2,
        "IN_MESTRADO" as in_mestrado,
        "IN_DOUTORADO" as in_doutorado,
        "NU_IDADE" as nu_idade,
        "NU_IDADE_REFERENCIA" as nu_idade_referencia,
        "CO_UF" as co_uf,
        "CO_MUNICIPIO" as co_municipio,
        "IN_ESPECIALIZACAO" as in_especializacao,
        "IN_POS_NENHUM" as in_pos_nenhum
    from {{ source('raw', 'gestor_2020') }}
    where "TP_DEPENDENCIA" != 4
)

select * from gestor_2019
union all
select * from gestor_2020
