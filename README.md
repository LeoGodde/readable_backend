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

## 📝 API Endpoints

- `GET /api/articles` - Listar artigos
- `POST /api/articles` - Criar novo artigo (envia URL para processamento)
- `GET /api/articles/:id` - Ver artigo específico
- `DELETE /api/articles/:id` - Remover artigo
- `GET /up` - Health check

## 🌐 Deploy

### Render.com (Recomendado)

Este projeto está configurado para deploy fácil no Render.com.

**Custo:** $14/mês (Web Service $7 + PostgreSQL $7)

```bash
# Ver seu RAILS_MASTER_KEY
./bin/render-setup

# Ou manualmente
cat config/master.key
```

Siga o guia completo: [docs/DEPLOY_RENDER.md](docs/DEPLOY_RENDER.md)

**Deploy rápido via Blueprint:**
1. Faça push do código para GitHub
2. Acesse: https://dashboard.render.com
3. New + → Blueprint
4. Conecte seu repositório
5. Cole seu RAILS_MASTER_KEY quando solicitado
6. Deploy automático! 🚀

## 📚 Documentação

- [Deploy no Render](docs/DEPLOY_RENDER.md)
- [HTML Sanitizer Resumo](HTML_SANITIZER_RESUMO.md)
- [Sanitizer Usage](SANITIZER_USAGE.md)
