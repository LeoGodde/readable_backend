# 🚀 Deploy no Render.com

Este guia detalha como fazer deploy do Readable Backend no Render.com.

## 💰 Custos Mensais

- **Web Service (Starter):** $7/mês
- **PostgreSQL (Starter):** $7/mês
- **Total:** $14/mês

## 📋 Pré-requisitos

1. Conta no [Render.com](https://render.com)
2. Repositório no GitHub conectado ao Render
3. Seu `RAILS_MASTER_KEY` (arquivo `config/master.key`)

## 🔑 Pegar o RAILS_MASTER_KEY

Execute no terminal:

```bash
cat config/master.key
```

**⚠️ IMPORTANTE:** Guarde esse valor em local seguro. Você vai precisar dele no Render.

## 📦 Opção 1: Deploy via Blueprint (render.yaml) - RECOMENDADO

### Passo 1: Fazer Push do render.yaml

O arquivo `render.yaml` já está configurado na raiz do projeto. Faça commit e push:

```bash
git add render.yaml docs/DEPLOY_RENDER.md
git commit -m "Add Render deployment configuration"
git push origin main
```

### Passo 2: Criar no Render via Blueprint

1. Acesse: https://dashboard.render.com
2. Clique em **"New +"** → **"Blueprint"**
3. Conecte seu repositório `readable_backend`
4. O Render detectará automaticamente o `render.yaml`
5. Preencha as variáveis de ambiente quando solicitado:
   - **RAILS_MASTER_KEY:** Cole o valor do seu `config/master.key`
6. Clique em **"Apply"**

O Render criará automaticamente:
- ✅ PostgreSQL Database
- ✅ Web Service
- ✅ Variáveis de ambiente configuradas
- ✅ Conexão entre o app e o banco

### Passo 3: Aguardar Deploy

- Primeiro deploy leva ~5-10 minutos
- Acompanhe os logs no Dashboard
- Quando terminar, você receberá uma URL: `https://readable-backend.onrender.com`

## 📦 Opção 2: Deploy Manual

### Passo 1: Criar PostgreSQL Database

1. No Dashboard, clique em **"New +"** → **"PostgreSQL"**
2. Configure:
   - **Name:** `readable-db`
   - **Database:** `readable_backend_production`
   - **User:** `readable_backend`
   - **Region:** oregon (ou sua preferência)
   - **Plan:** Starter ($7/mês)
3. Clique em **"Create Database"**
4. ⏳ Aguarde ~2 minutos
5. 📋 Copie a **"Internal Database URL"**

### Passo 2: Criar Web Service

1. No Dashboard, clique em **"New +"** → **"Web Service"**
2. Conecte seu repositório
3. Configure:
   - **Name:** `readable-backend`
   - **Region:** oregon (mesma do banco)
   - **Branch:** `main`
   - **Runtime:** Docker
   - **Dockerfile Path:** `./Dockerfile`
   - **Plan:** Starter ($7/mês)

### Passo 3: Configurar Variáveis de Ambiente

Na seção **"Environment Variables"**, adicione:

```
RAILS_MASTER_KEY=<cole_seu_master_key_aqui>
DATABASE_URL=<cole_a_internal_database_url_aqui>
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
RAILS_MAX_THREADS=5
```

### Passo 4: Configurar Health Check

- **Health Check Path:** `/up`

### Passo 5: Deploy

1. Clique em **"Create Web Service"**
2. Aguarde o build e deploy (~5-10 minutos)

## ✅ Verificar Deploy

Após o deploy completar:

### 1. Health Check
```bash
curl https://readable-backend.onrender.com/up
```

### 2. API de Artigos
```bash
curl https://readable-backend.onrender.com/api/articles
```

### 3. Ver Logs
No Dashboard → Seu Service → Aba "Logs"

## 🔄 Deploy Automático

Com o `render.yaml` configurado, todo push para `main` fará deploy automático!

```bash
git add .
git commit -m "Update feature"
git push origin main
# Deploy automático será iniciado! 🚀
```

## 🔧 Comandos Úteis

### Rodar Console do Rails

No Dashboard → Seu Service → Shell:

```bash
bundle exec rails console
```

### Rodar Migrações Manualmente

```bash
bundle exec rails db:migrate
```

### Ver Variáveis de Ambiente

No Dashboard → Seu Service → Environment

## 🌍 Domínio Customizado (Opcional)

1. No Dashboard → Seu Service → Settings → Custom Domains
2. Adicione seu domínio
3. Configure os DNS records (CNAME ou A record)
4. Render gera certificado SSL automaticamente via Let's Encrypt

## 📊 Monitoramento

### Logs em Tempo Real
Dashboard → Seu Service → Logs

### Métricas
Dashboard → Seu Service → Metrics
- CPU usage
- Memory usage
- Request count
- Response time

### Alertas
Dashboard → Seu Service → Settings → Notifications
- Configure alertas por email
- Integração com Slack/Discord/etc

## 🐛 Troubleshooting

### Deploy Falhou

1. Verifique os logs no Dashboard
2. Erros comuns:
   - `RAILS_MASTER_KEY` incorreto
   - `DATABASE_URL` não configurado
   - Migrações falharam

### App Está Lento

- Free tier: Apps dormem após 15min de inatividade
- Starter tier: Apps ficam sempre ativos
- Considere upgrade se necessário

### Banco de Dados Cheio

1. Ver uso: Dashboard → Database → Metrics
2. Upgrade de plano ou limpar dados antigos

## 🔐 Segurança

### Variáveis de Ambiente

- ✅ Nunca commite `config/master.key` no Git
- ✅ Use variáveis de ambiente no Render
- ✅ Rotacione secrets periodicamente

### Backups do Banco

- Render faz backups automáticos diários (Starter plan)
- Recuperação point-in-time disponível
- Baixe backups manualmente: Dashboard → Database → Backups

## 💡 Dicas de Otimização

### 1. Usar CDN (CloudFlare)

Configure CloudFlare na frente do Render para:
- Cache de assets
- DDoS protection
- SSL adicional

### 2. Configurar CORS

Se tiver frontend separado, configure CORS adequadamente.

### 3. Background Jobs

Seu app usa `solid_queue` que já está configurado para rodar no mesmo processo.

Para jobs pesados, considere:
- Criar um worker service separado
- Ou upgrade para plan com mais recursos

## 📞 Suporte

- **Documentação Render:** https://render.com/docs
- **Status do Render:** https://status.render.com
- **Suporte:** support@render.com

## 🎉 Pronto!

Seu Readable Backend está no ar! 🚀

URL da sua API: `https://readable-backend.onrender.com`
