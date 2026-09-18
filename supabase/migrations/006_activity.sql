-- 006_activity.sql
-- Immutable audit trail of important task actions. No update/delete policies are ever defined for it.

create table if not exists public.task_activity (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  task_id uuid not null references public.tasks (id) on delete cascade,
  user_id uuid references public.profiles (id) on delete set null,
  action text not null,
  old_value jsonb,
  new_value jsonb,
  metadata jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_activity_task_id on public.task_activity (task_id);
create index if not exists idx_activity_organization_id on public.task_activity (organization_id);
create index if not exists idx_activity_created_at on public.task_activity (created_at);
