# 🚀 Configuração Automática do Ambiente dbt + DuckDB

Este repositório contém um script Python para automatizar a criação de um ambiente dbt utilizando DuckDB como backend, facilitando o setup para novos projetos de dados.

## 📋 O que o script  `01_criacao_ambiente_dbt.py` faz ?

O script `01_criacao_ambiente_dbt.py` executa automaticamente:

- Criação de ambiente virtual Python (`.venv`)
- Instalação das dependências principais: `dbt-duckdb`, `pandas`, `duckdb`
- Criação do banco DuckDB (`meu_projeto_dbt/dev.duckdb`)
- Inicialização do projeto dbt (`meu_projeto_dbt`)
- Criação da estrutura de diretórios:
  - `models/raw` (dados brutos)
  - `models/staging` (dados em estágio)
  - `models/intermediate` (dados intermediários)
  - `models/mart` (dados finais)
- Teste de conexão com o banco
- Configuração dos arquivos de conexão do dbt

## 🎯 Como usar

### 2️⃣  O que faz o `02_duckdb_insercao_carga.ipynb`?

O notebook `02_duckdb_insercao_carga.ipynb` é responsável por:

- Mapear automaticamente todos os arquivos de dados em uma pasta de entrada.
- Conectar-se ao banco de dados DuckDB criado anteriormente.
- Criar (ou garantir a existência) do schema `raw` no banco.
- Inserir cada arquivo de dados como uma tabela separada no schema `raw`, detectando automaticamente o formato dos arquivos.
- Registrar logs das operações realizadas, facilitando o acompanhamento do processo.
- Preparar as zonas de dados para as próximas etapas do pipeline.

Este notebook é útil para automatizar a ingestão inicial de dados brutos no ambiente DuckDB, servindo como base para as transformações posteriores via dbt.


## 6️⃣ Comandos Recorrentes do dbt

Abaixo estão alguns dos comandos mais utilizados no dbt, com uma breve explicação de cada um:

- **`dbt run`**  
  Executa todos os modelos SQL do projeto, realizando as transformações e criando as tabelas/views no banco de dados.

- **`dbt test`**  
  Roda os testes definidos nos modelos e fontes, verificando integridade, unicidade, valores aceitos, relacionamentos, etc.

- **`dbt build`**  
  Executa uma sequência completa: compila, roda os modelos, testa e atualiza artefatos. É o comando recomendado para rodar tudo de ponta a ponta.

- **`dbt docs generate`**  
  Gera a documentação interativa do projeto, baseada nos arquivos YAML e nos modelos.

- **`dbt docs serve`**  
  Sobe um servidor local para navegar pela documentação gerada.

- **`dbt run --select nome_modelo`**  
  Executa apenas o(s) modelo(s) especificado(s), útil para rodar partes específicas do pipeline.

- **`dbt debug`**  
  Testa a configuração do ambiente e a conexão com o banco de dados.

- **`dbt clean`**  
  Remove diretórios e arquivos temporários criados pelo dbt, útil para "limpar" o ambiente.

Esses comandos são essenciais para o ciclo de desenvolvimento, teste e documentação de projetos dbt. Consulte sempre a [documentação oficial do dbt](https://docs.getdbt.com/docs/building-a-dbt-project/command-line-interface) para mais detalhes e opções avançadas.
