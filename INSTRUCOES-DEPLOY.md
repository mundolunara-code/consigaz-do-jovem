# Deploy do Consigaz ERP — GitHub + Vercel

Este é um site **estático de arquivo único** (`index.html`). Não tem build, não tem
Node, não tem variável de ambiente. O Vercel só serve o arquivo.

---

## Conteúdo desta pasta

| Arquivo | Para quê | Vai pro deploy? |
|---|---|---|
| `index.html` | O ERP completo | **SIM** (precisa ficar na raiz) |
| `vercel.json` | Configuração do Vercel | **SIM** |
| `licenciamento-supabase.sql` | Script do banco (rodar no Supabase) | Pode subir, não atrapalha |
| `COMO-CONFIGURAR-LICENCA.md` | Guia da licença mensal | Pode subir, não atrapalha |
| `INSTRUCOES-DEPLOY.md` | Este arquivo | Pode subir, não atrapalha |

O que **precisa** ir pro deploy é o `index.html` (na raiz) e o `vercel.json`.

---

## Passo a passo (pelo navegador, sem terminal)

### 1) GitHub — criar o repositório
1. Entre em https://github.com e clique em **New** (novo repositório).
2. Nome: `consigaz-erp` (ou o que preferir).
3. Deixe **Public** ou **Private** — tanto faz pro Vercel.
4. Clique em **Create repository**.

### 2) GitHub — subir os arquivos
1. Na página do repositório novo, clique em **uploading an existing file**.
2. Arraste os arquivos desta pasta (pelo menos `index.html` e `vercel.json`).
   > **IMPORTANTE:** o `index.html` tem que ficar na **raiz** do repositório,
   > não dentro de uma subpasta.
3. Clique em **Commit changes**.

### 3) Vercel — publicar
1. Entre em https://vercel.com e clique em **Add New → Project**.
2. Escolha o repositório `consigaz-erp`.
3. **Framework Preset:** deixe em **Other**.
4. **Build Command** e **Output Directory:** deixe em branco.
5. Clique em **Deploy**.

Em alguns segundos o Vercel te dá o link `https://consigaz-erp.vercel.app` no ar.

---

## Rotas públicas do sistema (funcionam sozinhas, por link)

- Página principal / login: `https://SEU-LINK.vercel.app/`
- Pedido online do cliente: `https://SEU-LINK.vercel.app/#/pedir`
- Acompanhar entrega: `https://SEU-LINK.vercel.app/#/acompanhar/TOKEN`

---

## Atualizar o sistema depois (nova versão)

1. No repositório do GitHub, entre no arquivo `index.html`.
2. Clique no lápis (**Edit**) ou em **Upload files** e substitua o `index.html`.
3. **Commit changes**.
4. O Vercel **publica sozinho** a nova versão em segundos. Não precisa fazer mais nada.

---

## Observações importantes

- **Os dados do ERP ficam salvos no aparelho** (navegador), não no Vercel.
  Trocar de navegador/computador ou limpar dados apaga o cadastro.
  Use o **Backup (JSON)** nas Configurações com frequência.
- A **licença mensal** só liga depois que você preencher as constantes no
  `index.html` e rodar o SQL no Supabase — veja `COMO-CONFIGURAR-LICENCA.md`.
  Enquanto não configurar, o app abre normalmente (licença desligada).
