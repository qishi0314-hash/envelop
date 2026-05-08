create table if not exists public.budget_states (
  sync_id text primary key,
  data jsonb not null,
  client_id text,
  updated_at timestamptz not null default now()
);

alter table public.budget_states enable row level security;

drop policy if exists "Anyone with a sync code can read budgets" on public.budget_states;
drop policy if exists "Anyone with a sync code can create budgets" on public.budget_states;
drop policy if exists "Anyone with a sync code can update budgets" on public.budget_states;

create policy "Anyone with a sync code can read budgets"
on public.budget_states
for select
to anon
using (true);

create policy "Anyone with a sync code can create budgets"
on public.budget_states
for insert
to anon
with check (true);

create policy "Anyone with a sync code can update budgets"
on public.budget_states
for update
to anon
using (true)
with check (true);

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'budget_states'
  ) then
    alter publication supabase_realtime add table public.budget_states;
  end if;
end $$;
