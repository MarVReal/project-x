-- 004_tags.sql
-- Organization-level tags with a many-to-many relation to tasks.

create table if not exists public.tags (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  name text not null,
  color text not null default '#6750A4',
  description text,
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  constraint tags_name_length check (char_length(name) between 1 and 100),
  unique (organization_id, name)
);

create index if not exists idx_tags_organization_id on public.tags (organization_id);

drop trigger if exists trg_tags_updated_at on public.tags;
create trigger trg_tags_updated_at
  before update on public.tags
  for each row execute function public.set_updated_at();

create table if not exists public.task_tags (
  task_id uuid not null references public.tasks (id) on delete cascade,
  tag_id uuid not null references public.tags (id) on delete cascade,
  organization_id uuid not null references public.organizations (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (task_id, tag_id)
);

create index if not exists idx_task_tags_tag_id on public.task_tags (tag_id);
create index if not exists idx_task_tags_organization_id on public.task_tags (organization_id);
