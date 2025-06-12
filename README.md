# Documentação Técnica - Bela CRM

## Visão Geral

O **Bela CRM** é uma plataforma de gestão para clínicas de estética, voltada para pequenas e médias empresas. Seu foco é proporcionar uma experiência simples, eficiente e escalável, com um modelo de negócio baseado em planos de uso (freemium e premium).

---

## Estrutura Inicial do Projeto

### Arquitetura

- **Frontend:** ReactJS + Shadcn UI
- **Backend:** Ruby on Rails API com Devise Token Auth
- **Estilização HTML no Backend:** Tailwind CSS (monolítico alternativo)
- **Banco de Dados:** PostgreSQL
- **Gerenciamento de dependências:** Docker + docker-compose

---

## Módulos Iniciais (MVP)

### 1. Accounts (multi-tenant)

- Criação de contas com CNPJ ou CPF opcional
- Cada conta possui usuários, clientes, agendamentos, planos, etc.
- Acesso inicial via `invitation_token`
- Campo `status` com enum: `pending`, `active`, `suspended`, `cancelled`
  - `pending`: conta criada mas ainda sem usuários
  - `active`: conta em uso normal
  - `suspended`: bloqueada por motivo administrativo
  - `cancelled`: encerrada pelo cliente ou sistema
- Campo `owner_user_id` armazena o ID do primeiro usuário responsável pela conta

### 2. Users (Devise Token Auth)

- Autenticação baseada em token para APIs
- Cada usuário pertence a uma única `account`
- O primeiro usuário da conta ativa o status `active`
- Roles: `user`, `admin`, `owner` para controle de permissões

### 3. Clients

- Cadastro de clientes da clínica
- Campos básicos: nome, telefone, e-mail, observações

### 4. Professionals

- Cadastro dos profissionais que realizam os atendimentos
- Campos: nome, função, especialidade

### 5. Appointments

- Agendamentos com data, hora, profissional e cliente
- Envio opcional de notificações via WhatsApp e e-mail

### 6. Plans

- Define os limites de uso da conta
- Campos:
  - `client_limit`
  - `professional_limit`
  - `appointments_limit`
  - `whatsapp_notifications_limit`
  - `email_notifications_limit`
  - `price_cents`
  - `interval`

### 7. Stock (Opcional - Etapa futura)

- Controle de produtos e movimentações de estoque
- Relacionamento opcional com serviços (ex: consumo por atendimento)

### 8. Financeiro (Etapa futura)

- Registro de receitas e despesas
- Relacionamento com agendamentos, contas a receber, meios de pagamento

---

## Plano de Assinaturas

| Plano   | Clientes  | Profissionais | Agendamentos/mês | WhatsApp | E-mail    | Valor     | Intervalo |
| ------- | --------- | ------------- | ---------------- | -------- | --------- | --------- | --------- |
| Free    | 50        | 1             | 50               | ❌        | 100       | R$ 0,00  | mensal    |
| Pro     | 500       | 3             | 300              | ✅        | 500       | R$ 29,90 | mensal    |
| Premium | Ilimitado | Ilimitado     | Ilimitado        | ✅        | Ilimitado | R$ 79,90 | mensal    |

**Valores armazenados em `price_cents` para evitar problemas de precisão com float.**

---

## Enum e Campos Opcionais

### Enum para `interval`

```ruby
enum interval: { monthly: 0, yearly: 1, lifetime: 2 }
```

Armazenado como `integer` para performance e consistência.

### Campos com `nil` para ilimitado

- `client_limit`, `professional_limit`, `appointments_limit`, `whatsapp_notifications_limit`, `email_notifications_limit`

Verificação exemplo:

```ruby
return false if plan.client_limit.nil?
clients.count >= plan.client_limit
```

---

## Considerações Finais

- O MVP terá limite de cadastros, agendamentos e usuários baseado em plano
- WhatsApp e notificações só disponíveis nos planos pagos
- Estoque e financeiro entrarão em versões futuras, com planejamento já previsto
- Uso de Devise Token Auth para autenticação com React frontend
- Contas iniciam com `status: pending` e só ativam após o primeiro usuário se registrar

---

## Fluxo de Cadastro e Escolha de Planos

### 🆓 Plano Gratuito (Free)

1. Cliente acessa a landing page → clica em "Comece agora gratuitamente"
2. Preenche o formulário de criação de conta (nome, e-mail, CPF/CNPJ opcional)
3. Backend cria a `account` com:
   - `status: pending`
   - `plan_id` vinculado ao plano Free
   - Gera `invitation_token`
4. Envia e-mail com link para criar o primeiro usuário
5. Ao criar o primeiro usuário, a conta se torna `active`
6. A clínica acessa o painel com limites do plano Free

✅ **Sem necessidade de cartão de crédito.**

---

### 💳 Plano Pago (Pro / Premium)

1. Cliente acessa a landing page → clica em "Quero um plano Premium"
2. Preenche os dados da clínica
3. Escolhe o plano Pro ou Premium
4. Redireciona para o checkout (ex: Stripe Checkout)
5. Cliente insere os dados do cartão e realiza o pagamento
6. Stripe retorna os dados: `customer_id`, `subscription_id`
7. Backend cria a `account` com:
   - `status: pending`
   - `plan_id` escolhido
   - Dados de cobrança salvos
   - Gera `invitation_token`
8. Envia e-mail para criação do primeiro usuário
9. Ao criar o primeiro usuário, a conta se torna `active`

---

### 🔄 Alternativa: Trial com Cartão Após

- Conta é ativada com trial de 7 ou 14 dias
- Mostra aviso no painel: "Faltam X dias para cadastrar forma de pagamento"
- Stripe inicia cobrança após o prazo

---

### 📌 Campos sugeridos

| Campo                | Tipo     | Descrição                          |
|---------------------|----------|------------------------------------|
| `plan_id`           | integer  | Referência ao plano escolhido      |
| `subscription_id`   | string   | ID da assinatura na Stripe         |
| `stripe_customer_id`| string   | ID do cliente no Stripe            |
| `trial_ends_at`     | datetime | Quando o trial termina             |

---

## Tratamento de Contas Não Ativadas

### 🧠 Situação

Usuários podem iniciar o cadastro, receber o convite (via `invitation_token`) e **não ativar a conta**. Depois, podem tentar se cadastrar novamente com o mesmo e-mail ou CNPJ/CPF.

### ✅ Estratégia de Prevenção

- Durante a criação da `account`, o backend verifica se já existe uma conta com o mesmo e-mail ou identificador (`identifier`) com status `pending`.
- Se houver, retorna uma resposta sugerindo reenvio do link de ativação.

### 🔁 Reenvio de Convite

- O sistema deve permitir o **reenvio do e-mail de ativação**
- Um novo `invitation_token` pode ser gerado e enviado ao usuário
- O frontend pode apresentar a opção: "Reenviar convite para ativar minha conta"

### 🧼 Expiração de contas pendentes (opcional)

- Após X dias (ex: 7), contas `pending` podem ser marcadas como `expired`
- Isso libera o uso do mesmo e-mail ou documento para um novo cadastro
- Pode ser automatizado com job diário

### 📌 Status útil para controle

| Status     | Descrição                                 |
|------------|-------------------------------------------|
| `pending`  | Criada, aguardando ativação               |
| `active`   | Em uso normal                             |
| `suspended`| Bloqueada por problemas administrativos   |
| `cancelled`| Encerrada manual ou automaticamente       |
| `expired`  | (Opcional) Expirou por falta de ativação  |

### 🚀 UX recomendada no frontend

- Detectar erro ao tentar criar conta duplicada
- Exibir aviso: “Já existe um cadastro em andamento com este e-mail.”
- Mostrar botão: **Reenviar link de ativação**

---

## Atualizações futuras

Este documento será expandido com:

- Fluxos de autenticação e convite (Devise + Multi-tenant)
- API pública vs interna
- Módulo de notificações e envio de mensagens
- Integração com gateways de pagamento (Stripe, Pagar.me, etc.)
- Testes automatizados (Minitest + cobertura por model)
