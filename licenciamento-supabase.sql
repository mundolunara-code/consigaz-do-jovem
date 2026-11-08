-- ============================================================
-- LICENCIAMENTO / COBRANÇA MENSAL — Consigaz ERP
-- Rode este script UMA VEZ no seu projeto Supabase:
-- Supabase > SQL Editor > New query > cole tudo > Run
-- ============================================================

-- 1) Tabela de licenças (uma linha por cliente/depósito)
create table if not exists public.licencas (
  id           uuid primary key default gen_random_uuid(),
  chave        text unique not null,          -- a chave que você entrega ao cliente
  cliente_nome text,                          -- nome do depósito (só p/ você identificar)
  ativo        boolean not null default true, -- desligue aqui para bloquear na hora
  valido_ate   date not null,                 -- data de vencimento da mensalidade
  criado_em    timestamptz default now()
);

-- 2) Segurança: liga o RLS e NÃO cria policy de leitura.
--    Assim, ninguém consegue listar/baixar as licenças usando a chave anon.
alter table public.licencas enable row level security;

-- 3) Função pública que o ERP chama para saber se a chave está em dia.
--    Ela roda com permissão elevada (security definer) e devolve APENAS
--    o status daquela chave — nunca a lista inteira.
create or replace function public.verificar_licenca(p_chave text)
returns json
language sql
security definer
set search_path = public
as $$
  select json_build_object(
           'ativo', ativo,
           'valido_ate', valido_ate,
           'nome', cliente_nome
         )
  from public.licencas
  where chave = p_chave;
$$;

-- 4) Permite que a chave anon (a do site) chame só essa função.
grant execute on function public.verificar_licenca(text) to anon;

-- ============================================================
-- COMO USAR NO DIA A DIA
-- ============================================================

-- Cadastrar um cliente novo (30 dias a partir de hoje):
-- insert into public.licencas (chave, cliente_nome, valido_ate)
-- values ('DEPOSITO-JOAO-2026', 'Depósito do João', current_date + interval '30 days');

-- Cliente pagou -> renovar por mais 30 dias:
-- update public.licencas
--   set valido_ate = greatest(valido_ate, current_date) + interval '30 days', ativo = true
--   where chave = 'DEPOSITO-JOAO-2026';

-- Cliente não pagou -> bloquear na hora:
-- update public.licencas set ativo = false where chave = 'DEPOSITO-JOAO-2026';

-- Reativar:
-- update public.licencas set ativo = true where chave = 'DEPOSITO-JOAO-2026';

-- Ver todos e seus vencimentos:
-- select cliente_nome, chave, ativo, valido_ate from public.licencas order by valido_ate;
