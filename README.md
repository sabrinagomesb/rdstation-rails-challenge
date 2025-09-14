# Desafio técnico e-commerce - Solução Implementada

## 📋 Sobre a Implementação

Esta é a solução completa para o desafio técnico de e-commerce da RD Station, implementando uma API REST para gerenciamento de carrinho de compras com funcionalidades avançadas de limpeza automática de carrinhos abandonados.

### ✨ Funcionalidades Implementadas

- **API REST completa** com 3 endpoints para gerenciamento de carrinho e 1 endpoint extra para listar todos os produtos
- **Sistema de carrinhos por sessão** com persistência automática
- **Job automatizado** para limpeza de carrinhos abandonados (3h → abandonado, 7 dias → removido)
- **Documentação Swagger/OpenAPI** interativa
- **Testes abrangentes** com RSpec e FactoryBot
- **Padronização de código** com RuboCop
- **Dockerização completa** com docker-compose

### 🛠️ Melhorias Adicionais

- **Documentação Swagger**: Interface interativa disponível em `/api-docs`
- **Tratamento de erros**: Validações robustas e mensagens de erro claras
- **Padronização**: RuboCop configurado para manter consistência de código
- **Serialização**: Active Model Serializers para respostas JSON estruturadas
- **Jobs otimizados**: Sistema eficiente de limpeza de carrinhos abandonados

## 🚀 Documentação da API

### 📖 Swagger/OpenAPI Documentation

A documentação interativa da API está disponível através do Swagger UI:

- **URL**: `http://localhost:3000/api-docs`
- **Arquivo YAML**: `http://localhost:3000/api-docs/v1/swagger.yaml`

A documentação inclui todos os endpoints, schemas de request/response, exemplos e permite testar a API diretamente na interface.

## 📋 Endpoints Implementados

A API REST implementa 4 endpoints para gerenciamento completo do carrinho de compras:

### 1. Adicionar produto ao carrinho

**POST** `/cart`

Adiciona um produto ao carrinho da sessão atual. Se não existir carrinho, cria um novo automaticamente.

**Request Body:**

```json
{
  "product_id": 345,
  "quantity": 2
}
```

**Response (201 Created):**

```json
{
  "id": 789,
  "products": [
    {
      "id": 645,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    }
  ],
  "total_price": 7.96
}
```

**Validações:**

- `product_id` deve existir no banco de dados
- `quantity` deve ser um número inteiro positivo
- Produto duplicado incrementa a quantidade existente

### 2. Listar itens do carrinho

**GET** `/cart`

Retorna todos os produtos do carrinho da sessão atual.

**Response (200 OK):**

```json
{
  "id": 789,
  "products": [
    {
      "id": 645,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    }
  ],
  "total_price": 7.96
}
```

**Comportamento:**

- Retorna carrinho vazio se não houver produtos
- Atualiza automaticamente o `last_interaction_at` do carrinho

### 3. Atualizar quantidade de produto

**PATCH** `/cart/add_item`

Atualiza a quantidade de um produto existente no carrinho.

**Request Body:**

```json
{
  "product_id": 1230,
  "quantity": 5
}
```

**Response (200 OK):**

```json
{
  "id": 1,
  "products": [
    {
      "id": 1230,
      "name": "Nome do produto X",
      "quantity": 5,
      "unit_price": 7.0,
      "total_price": 35.0
    }
  ],
  "total_price": 35.0
}
```

**Validações:**

- Produto deve existir no carrinho
- `quantity` deve ser um número inteiro positivo
- Retorna erro 404 se produto não estiver no carrinho

### 4. Remover produto do carrinho

**DELETE** `/cart/{product_id}`

Remove um produto específico do carrinho.

**Response (200 OK):**

```json
{
  "id": 1,
  "products": [],
  "total_price": 0.0
}
```

**Response (404 Not Found):**

```json
{
  "error": "Product not in cart"
}
```

**Comportamento:**

- Verifica se o produto existe no carrinho antes de remover
- Atualiza automaticamente o `total_price` do carrinho
- Retorna carrinho vazio se for o último produto

## 🔄 Sistema de Carrinhos Abandonados

### Implementação do Job Automatizado

O sistema implementa um job automatizado (`CleanupAbandonedCartsJob`) que executa a cada hora para gerenciar carrinhos abandonados:

**Cronograma:**

- **3 horas sem interação** → Carrinho marcado como `abandoned`
- **7 dias abandonado** → Carrinho removido permanentemente

**Configuração:**

```yaml
# config/sidekiq_scheduler.yml
cleanup_abandoned_carts:
  cron: '0 * * * *' # Executa a cada hora
  class: CleanupAbandonedCartsJob
  queue: default
```

**Funcionalidades:**

- Marca carrinhos sem interação há 3+ horas como abandonados
- Remove carrinhos abandonados há 7+ dias
- Atualiza `last_interaction_at` a cada operação no carrinho
- Execução otimizada com `find_each` para grandes volumes

## 🏗️ Arquitetura e Decisões Técnicas

### Estrutura de Dados

**Models Implementados:**

- `Product`: Produtos disponíveis no catálogo
- `Cart`: Carrinho de compras por sessão
- `CartItem`: Itens individuais no carrinho (relacionamento many-to-many)

**Migrações Criadas:**

```ruby
# 1. Criar CartItems (relacionamento Cart ↔ Product)
rails g migration CreateCartItems cart:references product:references quantity:integer

# 2. Adicionar status ao Cart
rails g migration AddStatusToCarts status:string

# 3. Adicionar controle de interação
rails g migration AddLastInteractionAtToCarts last_interaction_at:datetime
```

### Decisões de Design

**1. Sistema de Sessão:**

- Carrinho único por sessão (não precisa de `cart_id` na URL)
- ID do carrinho armazenado em `session[:cart_id]`
- Criação automática de carrinho quando necessário

**2. Unificação de Endpoints:**

- `POST /cart` e `PATCH /cart/add_item` poderiam ser unificados
- Mantidos separados conforme especificação do desafio (3 endpoints distintos)
- `POST /cart` → Adiciona produto (cria se não existir)
- `PATCH /cart/add_item` → Atualiza quantidade (produto deve existir)

**3. Validações Modernas:**

- Uso de `validates` em vez de `validates_presence_of` (padrão Rails 3.0+)
- Validações centralizadas nos models
- Tratamento de erros no `ApplicationController`

**4. Serialização:**

- `Active Model Serializers` para respostas JSON estruturadas
- Serializers específicos para cada model (`CartSerializer`)

### Qualidade de Código

**RuboCop Configurado:**

- Padronização automática de código
- Configuração em `.rubocop.yml`
- Execução: `bundle exec rubocop`

**Testes Abrangentes:**

- RSpec com FactoryBot
- Cobertura completa de models, controllers e jobs
- Testes de integração para endpoints
- Documentação Swagger gerada automaticamente pelos testes

## 🛠️ Informações Técnicas

### Dependências Principais

- **Ruby**: 3.3.1
- **Rails**: 7.1.3.2
- **PostgreSQL**: 16
- **Redis**: 7.0.15

### Dependências Adicionais

- **Sidekiq**: Processamento de jobs em background
- **Rswag**: Documentação Swagger/OpenAPI
- **Rack-CORS**: Configuração CORS para Swagger UI
- **Active Model Serializers**: Serialização JSON
- **RuboCop**: Linting e padronização de código
- **FactoryBot**: Criação de dados de teste
- **RSpec**: Framework de testes

## 🚀 Como Executar o Projeto

### Pré-requisitos

- Ruby 3.3.1
- PostgreSQL 16
- Redis 7.0.15

### Instalação e Configuração

1. **Instalar dependências:**

```bash
bundle install
```

2. **Configurar banco de dados:**

```bash
rails db:create
rails db:migrate
rails db:seed
```

3. **Executar Sidekiq (em terminal separado):**

```bash
bundle exec sidekiq
```

4. **Executar aplicação:**

```bash
bundle exec rails server
```

### Acessando a Aplicação

- **API**: `http://localhost:3000`
- **Swagger UI**: `http://localhost:3000/api-docs`
- **Documentação YAML**: `http://localhost:3000/api-docs/v1/swagger.yaml`

### Comandos Úteis

**Executar testes:**

```bash
bundle exec rspec
```

**Executar RuboCop:**

```bash
bundle exec rubocop
```

**Gerar documentação Swagger:**

```bash
RAILS_ENV=test bundle exec rspec spec/requests/*_swagger_spec.rb --format Rswag::Specs::SwaggerFormatter
```

**Executar com Docker:**

```bash
docker-compose up
```

## 📊 Resumo da Implementação

### ✅ Requisitos Atendidos

- [x] 3 endpoints REST para gerenciamento de carrinho
- [x] Sistema de carrinhos por sessão
- [x] Job automatizado para carrinhos abandonados
- [x] Testes abrangentes com RSpec
- [x] Documentação Swagger/OpenAPI
- [x] Dockerização completa
- [x] Padronização de código com RuboCop
- [x] Tratamento de erros robusto

### 🎯 Melhorias Implementadas

- **Documentação interativa** com Swagger UI
- **Sistema de jobs otimizado** para limpeza automática
- **Validações modernas** seguindo padrões Rails
- **Serialização estruturada** com Active Model Serializers
- **Cobertura de testes completa** incluindo jobs e documentação
- **Configuração CORS** para integração com Swagger UI

### 🔧 Decisões Técnicas

- Mantidos 3 endpoints distintos conforme especificação original
- Sistema de sessão para carrinhos (sem necessidade de ID na URL)
- Job único (`CleanupAbandonedCartsJob`) para ambas as operações de limpeza
- Validações centralizadas nos models
- Tratamento de erros no `ApplicationController`
