# Como ativar a cobrança mensal com bloqueio

O sistema já vem com o **portão de licença** embutido. Enquanto você não preencher os dados do Supabase, ele fica **desligado** (o ERP abre normal — bom para testar e demonstrar). Quando você preencher, ele passa a exigir uma chave válida para abrir o painel.

## Passo 1 — Criar o banco no Supabase
1. Acesse o seu projeto em https://supabase.com (ou crie um projeto novo, grátis).
2. Vá em **SQL Editor → New query**.
3. Cole todo o conteúdo do arquivo `licenciamento-supabase.sql` e clique em **Run**.
   - Isso cria a tabela `licencas` e a função `verificar_licenca`.

## Passo 2 — Pegar suas credenciais
No Supabase, vá em **Project Settings → API** e copie:
- **Project URL** (algo como `https://abcdefgh.supabase.co`)
- **anon public** key (uma chave longa)

## Passo 3 — Colar no sistema
Abra o arquivo `index.html` num editor de texto e, lá no começo do script, preencha:

```js
const LIC_SUPABASE_URL   = 'https://abcdefgh.supabase.co';  // sua Project URL
const LIC_SUPABASE_ANON  = 'sua-chave-anon-aqui';           // sua anon public
const LIC_TOLERANCIA_DIAS = 3;         // dias que o cliente pode ficar offline antes de travar
const LIC_CONTATO_WA      = '5521993026719';  // SEU WhatsApp p/ renovação (55 + DDD + número)
```

Salve e suba o `index.html` no Netlify (arrasta e solta, como sempre).

> A `anon public` pode ficar no arquivo sem problema — ela só consegue **perguntar** se uma chave está em dia (a função `verificar_licenca`). A lista de licenças fica protegida pelo RLS e **não** pode ser baixada por ela.

## Passo 4 — Cadastrar cada cliente
Para cada depósito que assinar, rode no SQL Editor (troque a chave e o nome):

```sql
insert into public.licencas (chave, cliente_nome, valido_ate)
values ('DEPOSITO-JOAO-2026', 'Depósito do João', current_date + interval '30 days');
```

Entregue a **chave** (`DEPOSITO-JOAO-2026`) ao cliente. Na primeira vez que ele abrir o sistema, aparece a tela **"Ative seu sistema"**; ele digita a chave e pronto.

## Passo 5 — Cobrar e controlar
- **Recebeu o pagamento:** renove por mais 30 dias
  ```sql
  update public.licencas
    set valido_ate = greatest(valido_ate, current_date) + interval '30 days', ativo = true
    where chave = 'DEPOSITO-JOAO-2026';
  ```
- **Não pagou:** o sistema **bloqueia sozinho** quando passa da data. Se quiser cortar na hora:
  ```sql
  update public.licencas set ativo = false where chave = 'DEPOSITO-JOAO-2026';
  ```

## Como funciona o bloqueio (resumo)
- Toda vez que o painel abre, ele pergunta ao Supabase se a chave está **ativa** e **dentro da validade**.
- Em dia → abre normal. Vencido/desativado → **tela de bloqueio** com seu WhatsApp para renovar.
- **Sem internet:** funciona por até `LIC_TOLERANCIA_DIAS` dias usando a última validação; depois trava pedindo conexão.
- As páginas públicas do cliente final (**/pedir** e **/acompanhar**) **não** são bloqueadas, para não prejudicar os clientes do depósito. (Dá para mudar isso se você preferir bloquear tudo.)

## Automatizar a cobrança (opcional, próximo passo)
Hoje você renova/bloqueia com um comando SQL (rápido e simples). Para deixar 100% automático — o cliente paga e o sistema libera sozinho — dá para ligar uma plataforma de recorrência (Kiwify, Cakto, Hotmart, Asaas, Vindi, Mercado Pago...) a uma **Edge Function** no Supabase que recebe o aviso de pagamento (webhook) e atualiza a data. Me chame quando quiser montar essa parte.

## Aviso honesto
Como o ERP roda no navegador do cliente, nenhuma trava é 100% impossível de burlar por alguém muito técnico. Mas a checagem no seu servidor (Supabase) levanta muito a barreira e, para donos de depósito, é mais que suficiente.
