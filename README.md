
# Documentação Técnica - Bela CRM

## Visão Geral
O **Bela CRM** é uma plataforma de gestão para clínicas de estética, voltada para pequenas e médias empresas. Seu foco é proporcionar uma experiência simples, eficiente e escalável, com um modelo de negócio baseado em planos de uso (freemium e premium).

---

## Estrutura Inicial do Projeto

### Arquitetura
- **Frontend:** ReactJS + Shadcn UI
- **Backend:** Ruby on Rails API
- **Estilização HTML no Backend:** Tailwind CSS (monolítico alternativo)
- **Banco de Dados:** PostgreSQL
- **Gerenciamento de dependências:** Docker + docker-compose

---

## Módulos Iniciais (MVP)

### 1. Accounts (multi-tenant)
- Criação de contas com CNPJ ou CPF opcional
- Cada conta possui usuários, clientes, agendamentos, planos, etc.
- Acesso inicial via `invitation_token`

### 2. Users (Devise)
- Autenticação, convite e vínculo com `account`
- Cada usuário pertence a uma única `account`

### 3. Clients
- Cadastro de clientes da clínica
- Campos básicos: nome, telefone, e-mail, observações

### 4. Professionals
- Cadastro dos profissionais que realizam os atendimentos
- Campos: nome, função, especialidade

### 5. Appointments
- Agendamentos com data, hora, profissional e cliente
- Envio opcional de notificações via WhatsApp (plano premium)

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

| Plano     | Clientes | Profissionais | Agendamentos/mês | WhatsApp | E-mail | Valor    | Intervalo  |
|-----------|----------|---------------|------------------|----------|--------|----------|------------|
| Free      | 50       | 1             | 50               | ❌        | 100    | R$ 0,00  | mensal     |
| Pro       | 500      | 3             | 300              | ✅        | 500    | R$ 29,90 | mensal     |
| Premium   | Ilimitado| Ilimitado     | Ilimitado        | ✅        | Ilimitado | R$ 79,90 | mensal     |

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

---

## Atualizações futuras
Este documento será expandido com:
- Fluxos de autenticação e convite (Devise + Multi-tenant)
- API pública vs interna
- Módulo de notificações e envio de mensagens
- Integração com gateways de pagamento (Stripe, Pagar.me, etc.)
- Testes automatizados (Minitest + cobertura por model)
