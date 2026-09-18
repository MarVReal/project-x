-- 002_pipelines_and_stages.sql
-- Pipelines represent a workflow; each pipeline has an ordered list of stages.

create table if not exists public.pipelines (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  name text not null,
  description text,
  color text not null default '#6750A4',
  icon text not null default 'account_tree',
  is_active boolean not null default true,
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  constraint pipelines_name_length check (char_length(name) between 1 and 150)
);

create index if not exists idx_pipelines_organization_id on public.pipelines (organization_id);

create trigger trg_pipelines_updated_at
  before update on public.pipelines
  for each row execute function public.set_updated_at();

create table if not exists public.pipeline_stages (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  pipeline_id uuid not null references public.pipelines (id) on delete cascade,
  name text not null,
  description text,
  color text not null default '#79747E',
  position integer not null default 0,
  is_completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  constraint pipeline_stages_name_length check (char_length(name) between 1 and 150),
  unique (pipeline_id, position)
);

create index if not exists idx_stages_organization_id on public.pipeline_stages (organization_id);
create index if not exists idx_stages_pipeline_id on public.pipeline_stages (pipeline_id);

create trigger trg_stages_updated_at
  before update on public.pipeline_stages
  for each row execute function public.set_updated_at();
