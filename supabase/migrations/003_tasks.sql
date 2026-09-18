-- 003_tasks.sql
-- The primary work item. Denormalizes organization_id for simple, indexable RLS checks.

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  pipeline_id uuid not null references public.pipelines (id) on delete restrict,
  stage_id uuid not null references public.pipeline_stages (id) on delete restrict,
  team_id uuid references public.teams (id) on delete set null,
  title text not null,
  description text,
  priority text not null default 'medium' check (priority in ('low', 'medium', 'high', 'urgent')),
  start_date date,
  due_date timestamptz,
  assigned_to uuid references public.profiles (id) on delete set null,
  created_by uuid references public.profiles (id) on delete set null,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  constraint tasks_title_length check (char_length(title) between 1 and 300),
  constraint tasks_due_after_start check (start_date is null or due_date is null or due_date::date >= start_date)
);

create index if not exists idx_tasks_organization_id on public.tasks (organization_id);
create index if not exists idx_tasks_pipeline_id on public.tasks (pipeline_id);
create index if not exists idx_tasks_stage_id on public.tasks (stage_id);
create index if not exists idx_tasks_assigned_to on public.tasks (assigned_to);
create index if not exists idx_tasks_team_id on public.tasks (team_id);
create index if not exists idx_tasks_due_date on public.tasks (due_date);
create index if not exists idx_tasks_created_at on public.tasks (created_at);
-- Trigram index to support fast ILIKE search on title/description. Uses whichever schema pg_trgm
-- is installed in at the time this runs (011_security_hardening.sql may relocate the extension
-- afterwards — that does not affect already-built indexes).
create index if not exists idx_tasks_title_trgm on public.tasks using gin (title gin_trgm_ops);
create index if not exists idx_tasks_description_trgm on public.tasks using gin (description gin_trgm_ops);

drop trigger if exists trg_tasks_updated_at on public.tasks;
create trigger trg_tasks_updated_at
  before update on public.tasks
  for each row execute function public.set_updated_at();
