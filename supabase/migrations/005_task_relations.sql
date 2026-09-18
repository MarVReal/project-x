-- 005_task_relations.sql
-- Comments, links, and attachment metadata for a task. Actual files live in Supabase Storage.

create table if not exists public.task_comments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  task_id uuid not null references public.tasks (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint task_comments_content_length check (char_length(content) between 1 and 5000)
);

create index if not exists idx_comments_task_id on public.task_comments (task_id);
create index if not exists idx_comments_organization_id on public.task_comments (organization_id);

drop trigger if exists trg_comments_updated_at on public.task_comments;
create trigger trg_comments_updated_at
  before update on public.task_comments
  for each row execute function public.set_updated_at();

create table if not exists public.task_links (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  task_id uuid not null references public.tasks (id) on delete cascade,
  title text not null,
  url text not null,
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  constraint task_links_title_length check (char_length(title) between 1 and 200),
  constraint task_links_url_format check (url ~* '^https?://')
);

create index if not exists idx_links_task_id on public.task_links (task_id);
create index if not exists idx_links_organization_id on public.task_links (organization_id);

create table if not exists public.task_attachments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  task_id uuid not null references public.tasks (id) on delete cascade,
  uploaded_by uuid references public.profiles (id) on delete set null,
  file_name text not null,
  storage_path text not null unique,
  file_size bigint not null check (file_size >= 0),
  mime_type text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_attachments_task_id on public.task_attachments (task_id);
create index if not exists idx_attachments_organization_id on public.task_attachments (organization_id);
