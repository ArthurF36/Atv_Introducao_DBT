# Introdução ao DBT

Desenvolvido por: Abílio Nogueira <br>
Fonte principal: [Dbt Docs](https://docs.getdbt.com/docs/build/documentation)
# 🧱 1. Conceitos de uma Stack Moderna para Pipeline de Dados

---

## 🔁 Pipeline de Dados

Um pipeline de dados é uma sequência de processos automatizados que captura, transforma e carrega dados de diversas fontes para um destino, normalmente com o objetivo de análise, visualização ou tomada de decisão.

### Etapas comuns:
- **Ingestão:** captura de dados (de APIs, bancos, arquivos etc.)
- **Transformação:** limpeza, enriquecimento e reestruturação dos dados
- **Armazenamento e consulta:** envio para bancos de dados, data warehouses ou data lakes
- **Consumo:** dashboards, modelos de ML, relatórios

---

## 🔄 ELT vs ETL

### ETL (Extract, Transform, Load):
- **Extração:** obtém dados da fonte
- **Transformação:** limpa e organiza antes de armazenar
- **Carga:** envia os dados prontos ao destino

🧠 **Usado quando:** há necessidade de transformar os dados antes de armazenar.

---

### ELT (Extract, Load, Transform):
- **Extração:** obtém dados da fonte
- **Carga:** carrega os dados brutos no destino
- **Transformação:** transforma os dados **dentro do banco** (ex: via SQL)

🧠 **Usado quando:** o banco de destino é potente e permite transformação rápida (ex: Snowflake, BigQuery, DuckDB)

---

## ⚙️ Ferramentas de Inserção

Essas ferramentas automatizam a **ingestão** de dados, conectando-se a APIs, arquivos ou bancos de dados.

### Exemplos:
- **Airbyte** – código aberto, permite conectar diversas fontes e destinos
- **Fivetran** – solução paga com foco em ELT
- **Singer** – especificação para ingestão de dados via arquivos "tap" e "target"
- **Python personalizado** – scripts para ingestão sob medida

---

## 🔧 Ferramentas de Pipelines de Dados

São usadas para **orquestrar** as etapas do pipeline (agendamento, monitoramento, dependências).

### Exemplos:
- **Prefect** – pipelines com foco em simplicidade e observabilidade
- **Dagster** – design modular, com foco em desenvolvimento e validação
- **Airflow** – robusto e altamente configurável, ideal para ambientes complexos
- **Luigi** – bom para pipelines locais e dependências simples
- **Make / bash / crontab** – soluções caseiras e simples para fluxos pequenos

---

## 🧱 Banco de Dados Colunares

Diferente dos bancos tradicionais (linha a linha), os bancos colunares armazenam os dados **por coluna**, o que permite otimizações para consultas analíticas.

### 🆚 Banco de Dados Colunares vs Relacionais

| Característica      | Relacional (row-based) | Colunar (columnar)       |
|---------------------|------------------------|--------------------------|
| Armazenamento       | Linha por linha        | Coluna por coluna        |
| Otimizado para      | Escrita, OLTP          | Leitura, OLAP            |
| Exemplos            | PostgreSQL, MySQL      | DuckDB, ClickHouse, BigQuery |

---

## 🦆 DuckDB

DuckDB é um banco de dados analítico **colunar**, projetado para rodar **localmente**, dentro do seu processo Python (sem servidor).

### Vantagens:
- Extremamente leve (sem necessidade de servidor)
- Suporte nativo a formatos como Parquet e CSV
- Integração direta com pandas, Arrow e NumPy
- Alta performance em queries analíticas
- Ideal para prototipação e ambientes de desenvolvimento

---

## 🧪 Formas de Uso do DuckDB

- Como banco **embutido** em scripts e notebooks
- Com arquivos locais `.csv`, `.parquet`, `.json`
- Para consultar **DataFrames diretamente** (sem gravar no disco)
- Como camada intermediária de análise antes de enviar para um warehouse

### Exemplos:
```python
import duckdb
import pandas as pd

df = pd.read_csv("dados.csv")
duckdb.query("SELECT * FROM df WHERE valor > 100").to_df()
```




# 🧩 2. Utilizando o DBT (Data Build Tool)

---

## 📌 O que é o DBT?

DBT (Data Build Tool) é uma ferramenta que permite aplicar princípios de engenharia de software à transformação de dados no ambiente de dados analíticos.

🎯 **Propósito:** Transformar dados já carregados em um banco de dados (ex: DuckDB, BigQuery, Redshift) usando **SQL modular, versionado e testado**.

---

## ⚙️ Como funciona o DBT?

1. Você cria **models** em arquivos SQL, organizados por camadas (ex.: `staging/`, `intermediate/`, `marts/`).
2. DBT converte esses arquivos em SQL executável no warehouse, respeitando dependências (via `ref()`).
3. Gera documentação visual, realiza testes de qualidade, cria lineage (linhagem) e suporta versionamento com Git.
4. Não é ferramenta de ingestão ou visualização — foca na transformação (`T` de ELT).

🎯 Você **não move dados com o DBT**, mas transforma **dados já existentes no banco**.

---

## ☁️ Dbt Cloud vs 🖥️ Dbt Core

| Item             | DBT Cloud                        | DBT Core (open source)         |
|------------------|----------------------------------|-------------------------------|
| Interface        | Web, com UI e agendador          | Linha de comando (CLI)        |
| Infraestrutura   | DBT executa na nuvem             | Você executa localmente       |
| Preço            | Gratuito (limitado) / Pago       | Gratuito                      |
| Recursos extras  | Scheduler, logs, alertas, UI     | Totalmente manual             |
| Ideal para       | Equipes e ambientes gerenciados  | Aprendizado e pequenos projetos |

---

## 🧱 Organização das camadas: raw → staging → intermediate → serving

O DBT incentiva uma estrutura em **camadas**, baseada em boas práticas de modelagem de dados analíticos:


1. **Staging** (`models/staging/`)  
   - Prepara os dados "atomizados" vindos das fontes (raw), usando **sources**.  
   - Renomeia colunas, padroniza tipos e formatos.  
   - Serve de única referência às tabelas de origem, reduzindo acoplamento.  


2. **Intermediate** (`models/intermediate/`)  
   - Agrega lógica de negócio intermediária.  
   - Organiza os dados por grupo de negócio (ex.: `finance/`, `marketing/`).  
   - Geralmente possui verbos na nomenclatura (ex.: `int_payments_pivoted_to_orders.sql`)  


3. **Marts** (ou **Marts**) (`models/marts/`)  
   - Dados finais preparados para análise e relatórios.  
   - Combina dados processados para formar as entidades úteis para o negócio. 

📌 Essa organização modulariza o projeto e facilita a manutenção e entendimento do fluxo de dados.

Além dessas, também podem existir:
- **raw**— Dados integralmente copiados de outras fontes de dados, onde não é aplicada nenhuma alteração.
- **utilities** — modelos utilitários reutilizáveis (ex.: tabela de datas), não contêm dados de negócios propriamente ditos.  

---

## 🔧 O que o DBT faz?

✅ Transforma dados com SQL  
✅ Controla dependências entre modelos  
✅ Roda transformações com versionamento (Git)  
✅ Valida com **testes automatizados**  
✅ Documenta todo o projeto com **interface navegável**  
✅ Gera **lineage (linhagem)** de dados para rastrear o fluxo

---

## 🚫 O que o DBT **não faz**

⛔ Não extrai dados de fontes (não faz ingestão)  
⛔ Não carrega dados para o banco (não é ETL completo)  
⛔ Não cria dashboards ou relatórios  
⛔ Não armazena dados em si  
⛔ Não é ferramenta de Machine Learning

---

## 📚 Documentação com DBT

Com um único comando (`dbt docs generate`), o DBT cria uma documentação HTML com:

- Definição de cada modelo
- Descrição das colunas
- Relações entre tabelas (lineage)
- Testes aplicados
- Seeds, snapshots, macros

📎 É possível acessar via navegador (`dbt docs serve`) ou publicar no DBT Cloud.

---

## ✅ Testes no DBT

DBT possui testes **integrados e customizados**, aplicados diretamente no SQL.

### Testes integrados (genéricos):
```yml
models:
  - name: vendas
    columns:
      - name: id_venda
        tests:
          - unique
          - not_null
```

# 🚀 2.1. DBT Avançado

Neste tópico, exploramos funcionalidades mais avançadas do DBT que tornam os projetos mais dinâmicos, reutilizáveis e auditáveis: **macros**, **snapshots** e **seeds**.

---

## 🧠 2.1.1. Macros

### O que são?
Macros são **funções reutilizáveis** escritas em Jinja (um template engine para Python), usadas para gerar SQL dinamicamente dentro do DBT.

🔁 **Servem para:**
- Reduzir repetição de código SQL
- Criar lógica condicional ou parametrizada
- Padronizar transformações

---

### Exemplo básico de macro

📁 Arquivo: `macros/formatar_datas.sql`

```sql
{% macro formatar_data(coluna) %}
    date_trunc('day', {{ coluna }})
{% endmacro %}
```


```sql
SELECT
    {{ formatar_data("data_pedido") }} AS data_formatada
FROM {{ ref('stg_pedidos') }}
```

## 🧬 2.1.2 Snapshots

### O que são?

Snapshots são usados para capturar mudanças históricas em dados dimensionais, como SCDs (Slowly Changing Dimensions). Eles permitem rastrear como um registro mudou ao longo do tempo.

🔁 **Servem para:**
Você tem uma tabela de clientes e deseja registrar cada vez que o endereço de um cliente mudar, mantendo o histórico.

### Exemplo básico de snapshot
📁 Arquivo: snapshots/clientes_snapshot.sql

```sql
{% snapshot clientes_snapshot %}

{{
  config(
    target_schema='snapshots',
    unique_key='id_cliente',
    strategy='check',
    check_cols=['nome', 'email', 'endereco']
  )
}}

SELECT * FROM {{ source('vendas', 'clientes') }}

{% endsnapshot %}

```

📁 dbt_project.yml (configuração):

```yaml
snapshots:
  my_dbt_project:
    +target_schema: snapshots
    +strategy: check
```

## 🌱 2.1.3  Seeds

### O que são?

Seeds são arquivos CSV usados como tabelas estáticas no projeto DBT. Ideal para dados pequenos e constantes como tabelas de referência, códigos de UF, calendários etc.

🔁 **Como funciona:**
1. Salve um CSV na pasta /seeds/

2. Execute dbt seed

3. O DBT converte o CSV em uma tabela no banco de dados


### Resumo 
```plaintext
macros/
├── utilitarios.sql   # funções Jinja para SQL dinâmico

snapshots/
├── clientes_snapshot.sql   # monitora mudanças históricas

seeds/
├── calendario.csv          # dados estáticos
├── tipo_produto.csv

```


# 🗂️ 3. Estrutura de um Projeto DBT

Um projeto DBT é organizado em uma estrutura de pastas e arquivos que promove boas práticas de engenharia de software, como modularidade, reutilização e testabilidade. Abaixo, detalhamos cada componente.

---

## 📂 Estrutura de Pastas Principal

Um projeto DBT típico tem a seguinte aparência:

```plaintext
meu_projeto_dbt/
├── models/                 # Onde ficam os modelos de transformação (SQL, Python)
├── seeds/                  # Arquivos CSV com dados estáticos
├── tests/                  # Testes de dados personalizados (singulares)
├── macros/                 # Funções reutilizáveis (Jinja + SQL)
├── snapshots/              # Configuração para capturar mudanças históricas (SCD)
├── dbt_project.yml         # Arquivo principal de configuração do projeto
```

---

## 🧾 Arquivos de Configuração

### `dbt_project.yml`
É o coração do projeto. Este arquivo define:
- **Nome do projeto** e versão.
- **Perfil de conexão** a ser usado (do arquivo `profiles.yml`).
- **Caminhos** onde o DBT deve procurar por cada tipo de recurso (`model-paths`, `seed-paths`, etc.).
- **Configurações globais** para modelos, como materialização (`table`, `view`, `incremental`).

**Exemplo:**
```yaml
name: 'meu_projeto_dbt'
version: '1.0.0'
profile: 'default' # Nome do perfil de conexão

# Define onde cada tipo de recurso está localizado
model-paths: ["models"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

# Configuração padrão para todos os modelos dentro do projeto
models:
  meu_projeto_dbt:
    # Modelos na pasta staging serão materializados como views
    staging:
      materialized: view
    # Modelos na pasta marts serão materializados como tabelas
    marts:
      materialized: table
```

### `packages.yml`
Usado para declarar dependências de pacotes externos, como o `dbt-utils`, que oferece um conjunto de macros úteis.

---

## `models/` – A Camada de Transformação

Esta é a pasta mais importante, onde toda a lógica de transformação de dados reside.

### Organização em Camadas
Os modelos são organizados em subpastas que representam as camadas do pipeline, conforme visto anteriormente:
- `models/staging/`: Modelos que fazem a limpeza e padronização inicial dos dados brutos (`sources`). Cada fonte de dados deve ter seu próprio modelo de staging.
- `models/intermediate/`: Modelos que aplicam lógica de negócio intermediária, como junções (`joins`) e agregações complexas.
- `models/marts/`: Modelos finais, prontos para consumo por ferramentas de BI ou outras aplicações. Representam entidades de negócio (ex: `dim_clientes`, `fct_pedidos`).

### Arquivos de Modelo (`.sql` e `.py`)
- **`.sql`**: A grande maioria dos modelos são arquivos SQL. Neles, você usa as funções `{{ ref(...) }}` para criar dependências entre modelos e `{{ source(...) }}` para referenciar dados brutos.

  _Exemplo (`models/staging/stg_pedidos.sql`):_
  ```sql
  SELECT
      id AS id_pedido,
      id_cliente,
      status,
      valor AS valor_total
  FROM {{ source('loja', 'pedidos') }} -- Referencia a fonte de dados brutos
  ```

- **`.py`**: Para transformações mais complexas que SQL não suporta bem (requer um data warehouse compatível como Snowflake, Databricks ou BigQuery).

### Arquivos de Propriedades (`.yml`)
Junto aos modelos, arquivos `.yml` são usados para documentar, adicionar testes e definir configurações específicas.

- **Declaração de `sources`**: Mapeia as tabelas de dados brutos.
- **Descrição de `models` e colunas**: Adiciona metadados que aparecem na documentação.
- **Testes genéricos**: Aplica testes pré-definidos (`unique`, `not_null`, `accepted_values`, `relationships`).

_Exemplo (`models/staging/stg_loja.yml`):_
```yaml
version: 2

sources:
  - name: loja
    description: "Dados brutos do e-commerce."
    database: raw
    schema: public
    tables:
      - name: pedidos
      - name: clientes

models:
  - name: stg_pedidos
    description: "Modelo de staging para pedidos. Uma linha por pedido."
    columns:
      - name: id_pedido
        description: "Chave primária do pedido."
        tests:
          - unique
          - not_null
      - name: status
        tests:
          - accepted_values:
              values: ['entregue', 'enviado', 'processando', 'cancelado']
```

---

## Outras Pastas Essenciais

### `seeds/`
- **O que faz**: Armazena arquivos `.csv` com dados estáticos (ex: tabela de feriados, lista de UFs, categorias de produtos).
- **Comando**: `dbt seed` carrega esses arquivos como tabelas no seu banco de dados.
- **Uso**: Podem ser referenciados em modelos usando a função `{{ ref('nome_do_arquivo_seed') }}`.

### `tests/`
- **O que faz**: Contém testes de dados personalizados (chamados de "singulares"), que são consultas SQL que devem retornar zero linhas para o teste passar.
- **Exemplo (`tests/assert_valor_total_positivo.sql`):**
  ```sql
  -- Se esta consulta retornar alguma linha, o teste falha.
  SELECT
      id_pedido,
      valor_total
  FROM {{ ref('stg_pedidos') }}
  WHERE valor_total < 0
  ```

### `macros/`
- **O que faz**: Define macros em Jinja, que são pedaços de código SQL reutilizáveis. Útil para evitar repetição e padronizar lógica.
- **Exemplo (`macros/formatar_moeda.sql`):**
  ```sql
  {% macro formatar_moeda(coluna) %}
      ({{ coluna }} / 100)::numeric(16, 2)
  {% endmacro %}
  ```
- **Uso no modelo**: `SELECT {{ formatar_moeda('valor_centavos') }} AS valor_reais FROM ...`

### `snapshots/`
- **O que faz**: Permite capturar o histórico de mudanças em uma tabela (Slowly Changing Dimensions - SCD Tipo 2).
- **Comando**: `dbt snapshot` executa a lógica para versionar os dados.
- **Configuração**: Um arquivo `.sql` define a query e a estratégia para detectar mudanças (`check` ou `timestamp`).

# 📚 5. Documentação no DBT

A documentação é um dos pilares do dbt, permitindo que qualquer pessoa na organização entenda o que os dados significam, como são transformados e qual a sua linhagem.

---

## 🎯 Definição

A documentação no dbt consiste em **metadados** escritos em arquivos `.yml` que descrevem seus recursos, como:
- **Models**: O que um modelo representa? Qual a sua finalidade?
- **Columns**: O que cada coluna significa? Qual o seu formato?
- **Sources**: De onde vêm os dados brutos? Com que frequência são atualizados?
- **Tests**: Quais garantias de qualidade são aplicadas a um determinado campo?

Ao executar o comando `dbt docs generate`, o dbt compila todo o conteúdo dos seus arquivos `.yml` e `.sql` em um **site estático, interativo e local**, que serve como um dicionário de dados e um mapa do seu pipeline.

---

## ✨ Importância

Manter a documentação junto com o código de transformação traz enormes benefícios:

- **Fonte Única da Verdade (SSOT)**: Centraliza o conhecimento sobre os dados, evitando planilhas e documentos desatualizados.
- **Data Discovery**: Facilita a descoberta de quais dados estão disponíveis e como podem ser usados para análise.
- **Confiança e Governança**: Aumenta a confiança nos dados ao expor a lógica de transformação, os testes de qualidade e a linhagem de ponta a ponta.
- **Colaboração**: Permite que analistas, engenheiros e stakeholders de negócio falem a mesma língua, usando as mesmas definições.

---

## 📍 Localização dos Arquivos

Os arquivos de documentação (`.yml`) são flexíveis, mas a convenção é colocá-los **dentro da pasta `models/`**, próximos aos recursos que eles descrevem.

Por exemplo, para um modelo `stg_pedidos.sql`, o ideal é ter um arquivo `stg_pedidos.yml` na mesma pasta.

**Estrutura de exemplo:**
```plaintext
models/
└── staging/
    ├── stg_clientes.sql
    ├── stg_pedidos.sql
    └── stg_loja.yml  # Documenta todos os modelos e fontes da camada staging
```
É possível ter um arquivo `.yml` para cada modelo ou um arquivo que documenta vários modelos e fontes de uma só vez, como no exemplo acima.

---

## 📝 Exemplo Completo

Este exemplo de arquivo `yml` documenta uma fonte (`source`) e um modelo (`model`), incluindo descrições e testes.

📁 `models/staging/stg_ecommerce.yml`:
```yaml
version: 2

sources:
  - name: ecommerce_raw # Nome da fonte, usado em {{ source(...) }}
    description: "Dados brutos da plataforma de e-commerce."
    database: raw
    schema: public
    tables:
      - name: pedidos
        description: "Registra cada pedido feito na plataforma."
        columns:
          - name: id
            description: "Chave primária da tabela de pedidos."
            tests:
              - unique
              - not_null

models:
  - name: stg_pedidos # Nome do arquivo .sql (sem a extensão)
    description: "Modelo de staging para pedidos. Limpa e padroniza os dados brutos de pedidos. Uma linha por pedido."
    columns:
      - name: id_pedido
        description: "Chave primária do modelo de pedidos."
        tests:
          - unique
          - not_null
      - name: status_pedido
        description: "Status atual do pedido."
        tests:
          - accepted_values:
              values: ['processando', 'enviado', 'entregue', 'cancelado']
      - name: id_cliente
        description: "Chave estrangeira para o cliente que fez o pedido."
        tests:
          - relationships:
              to: ref('stg_clientes')
              field: id_cliente
```

---

## 🚀 Comandos Essenciais

1.  **`dbt docs generate`**: Compila o site da documentação.
2.  **`dbt docs serve`**: Inicia um servidor web local para navegar pela documentação gerada.


# 📝 6. Comandos Mais Frequentes do DBT

Aqui estão os comandos mais comuns que você usará no seu dia a dia com o dbt Core:

- **`dbt run`**: Executa todos os modelos na sua pasta `models`. É o comando principal para rodar suas transformações.
  - **`dbt run --select <nome_do_modelo>`**: Executa um modelo específico.
  - **`dbt run --select staging`**: Executa todos os modelos em uma pasta.
  - **`dbt run --full-refresh`**: Força a recriação de modelos incrementais.

- **`dbt test`**: Executa todos os testes de dados definidos no seu projeto (genéricos e singulares).
  - **`dbt test --select <nome_do_modelo>`**: Testa apenas um modelo específico.

- **`dbt build`**: Um atalho que executa `dbt run`, `dbt test`, `dbt seed` e `dbt snapshot` em uma única etapa, na ordem correta de dependências.

- **`dbt compile`**: Compila o seu código Jinja para SQL puro, sem executá-lo. Útil para depuração.

- **`dbt seed`**: Carrega os arquivos CSV da sua pasta `seeds` como tabelas no seu data warehouse.

- **`dbt snapshot`**: Executa os snapshots para capturar o histórico de mudanças nos seus dados.

- **`dbt docs generate`**: Gera o site de documentação do seu projeto.

- **`dbt docs serve`**: Inicia um servidor web local para visualizar a documentação gerada.

- **`dbt deps`**: Baixa as dependências de pacotes listadas no seu arquivo `packages.yml`.

- **`dbt clean`**: Remove as pastas `target/` e `dbt_packages/`, limpando os artefatos de compilação.

- **`dbt debug`**: Ajuda a diagnosticar problemas de conexão com o seu banco de dados.
