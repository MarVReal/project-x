-- 007_notifications.sql
-- In-app notifications. Rows are written server-side (service role) — see NEXT_STEPS.txt.

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  type text not null,
  title text not null,
  message text not null,
  task_id uuid references public.tasks (id) on delete cascade,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_notifications_user_id on public.notifications (user_id);
create index if not exists idx_notifications_organization_id on public.notifications (organization_id);
create index if not exists idx_notifications_is_read on public.notifications (is_read);
