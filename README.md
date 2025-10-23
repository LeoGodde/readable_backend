# 📚 Readable Backend

Backend Rails para o projeto Readable - uma aplicação para salvar e processar documentos HTML.

## 🚀 Tecnologias

- Ruby on Rails 8.1.0
- PostgreSQL
- Docker & Docker Compose
- Solid Cache, Solid Queue, Solid Cable

## 📦 Pré-requisitos

- Docker
- Docker Compose

## ⚙️ Setup com Docker

```bash
# 1. Clonar repositório
git clone git@github.com:LeoGodde/readable_backend.git
cd readable_backend

# 2. Build e iniciar containers
docker-compose up -d

# 3. Setup do banco de dados
rails db:create
rails db:migrate

# 4. Acessar aplicação
# http://localhost:3000
```

## 🧪 Comandos Úteis

```bash
# Iniciar containers
docker-compose up -d

# Parar containers
docker-compose down

# Logs da aplicação
docker-compose logs -f web

# Console Rails
rails c

# Servidor Rails
rails s

# Testes
rails test

# Ver rotas
rails routes
```

## 🔧 Desenvolvimento Local (sem Docker)

Se preferir rodar localmente, instale PostgreSQL e:

```bash
bundle install
rails db:create db:migrate
rails server
```

## 📝 API Endpoints (planejado)

- `GET /documents` - Listar documentos
- `POST /documents` - Criar novo documento
- `GET /documents/:id` - Ver documento específico
- `PUT/PATCH /documents/:id` - Atualizar documento
- `DELETE /documents/:id` - Remover documento
