-- 009_rls.sql
-- Enables Row Level Security on every table and defines policies using the helper functions from
-- 008_helper_functions.sql. This is the real authorization boundary — Angular guards are UX only.
-- Every policy is preceded by `drop policy if exists` so this file is safe to re-run.

alter table public.organizations enable row level security;
alter table public.profiles enable row level security;
alter table public.teams enable row level security;
alter table public.organization_members enable row level security;
alter table public.pipelines enable row level security;
alter table public.pipeline_stages enable row level security;
alter table public.tasks enable row level security;
alter table public.tags enable row level security;
alter table public.task_tags enable row level security;
alter table public.task_comments enable row level security;
alter table public.task_links enable row level security;
alter table public.task_attachments enable row level security;
alter table public.task_activity enable row level security;
alter table public.notifications enable row level security;

-- ORGANIZATIONS -------------------------------------------------------------
drop policy if exists "organizations_select_member" on public.organizations;
create policy "organizations_select_member" on public.organizations
  for select using (public.is_organization_member(id));

-- Only signed-in users may create an organization; the creator is auto-added as admin via the
-- on_organization_created trigger (see 001_initial_schema.sql).
drop policy if exists "organizations_insert_self" on public.organizations;
create policy "organizations_insert_self" on public.organizations
  for insert to authenticated
  with check (auth.uid() is not null);

drop policy if exists "organizations_update_admin" on public.organizations;
create policy "organizations_update_admin" on public.organizations
  for update using (public.is_admin(id)) with check (public.is_admin(id));

-- PROFILES --------------------------------------------------------------
drop policy if exists "profiles_select_self_or_org" on public.profiles;
create policy "profiles_select_self_or_org" on public.profiles
  for select using (id = auth.uid() or public.shares_organization_with(id));

drop policy if exists "profiles_update_self" on public.profiles;
create policy "profiles_update_self" on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

-- TEAMS -------------------------------------------------------------------
drop policy if exists "teams_select_member" on public.teams;
create policy "teams_select_member" on public.teams
  for select using (public.is_organization_member(organization_id));

drop policy if exists "teams_manage_admin" on public.teams;
create policy "teams_manage_admin" on public.teams
  for insert with check (public.is_admin(organization_id));

drop policy if exists "teams_update_admin" on public.teams;
create policy "teams_update_admin" on public.teams
  for update using (public.is_admin(organization_id)) with check (public.is_admin(organization_id));

drop policy if exists "teams_delete_admin" on public.teams;
create policy "teams_delete_admin" on public.teams
  for delete using (public.is_admin(organization_id));

-- ORGANIZATION MEMBERS ----------------------------------------------------
drop policy if exists "org_members_select_member" on public.organization_members;
create policy "org_members_select_member" on public.organization_members
  for select using (public.is_organization_member(organization_id));

drop policy if exists "org_members_insert_admin" on public.organization_members;
create policy "org_members_insert_admin" on public.organization_members
  for insert with check (public.is_admin(organization_id));

drop policy if exists "org_members_update_admin_or_self" on public.organization_members;
create policy "org_members_update_admin_or_self" on public.organization_members
  for update using (public.is_admin(organization_id) or user_id = auth.uid())
  with check (public.is_admin(organization_id) or user_id = auth.uid());

drop policy if exists "org_members_delete_admin" on public.organization_members;
create policy "org_members_delete_admin" on public.organization_members
  for delete using (public.is_admin(organization_id));

-- PIPELINES -----------------------------------------------------------------
drop policy if exists "pipelines_select_member" on public.pipelines;
create policy "pipelines_select_member" on public.pipelines
  for select using (public.is_organization_member(organization_id));

drop policy if exists "pipelines_insert_admin" on public.pipelines;
create policy "pipelines_insert_admin" on public.pipelines
  for insert with check (public.is_admin(organization_id));

drop policy if exists "pipelines_update_admin" on public.pipelines;
create policy "pipelines_update_admin" on public.pipelines
  for update using (public.is_admin(organization_id)) with check (public.is_admin(organization_id));

drop policy if exists "pipelines_delete_admin" on public.pipelines;
create policy "pipelines_delete_admin" on public.pipelines
  for delete using (public.is_admin(organization_id));

-- PIPELINE STAGES -------------------------------------------------------
drop policy if exists "stages_select_member" on public.pipeline_stages;
create policy "stages_select_member" on public.pipeline_stages
  for select using (public.is_organization_member(organization_id));

drop policy if exists "stages_insert_admin" on public.pipeline_stages;
create policy "stages_insert_admin" on public.pipeline_stages
  for insert with check (public.is_admin(organization_id));

drop policy if exists "stages_update_admin" on public.pipeline_stages;
create policy "stages_update_admin" on public.pipeline_stages
  for update using (public.is_admin(organization_id)) with check (public.is_admin(organization_id));

drop policy if exists "stages_delete_admin" on public.pipeline_stages;
create policy "stages_delete_admin" on public.pipeline_stages
  for delete using (public.is_admin(organization_id));

-- TASKS -----------------------------------------------------------------
drop policy if exists "tasks_select_authorized" on public.tasks;
create policy "tasks_select_authorized" on public.tasks
  for select using (
    public.is_organization_member(organization_id)
    and (
      public.is_admin(organization_id)
      or (public.is_section_head(organization_id) and team_id = public.user_team_id(organization_id))
      or assigned_to = auth.uid()
      or created_by = auth.uid()
    )
  );

drop policy if exists "tasks_insert_admin_or_section_head" on public.tasks;
create policy "tasks_insert_admin_or_section_head" on public.tasks
  for insert with check (public.is_section_head(organization_id));

drop policy if exists "tasks_update_authorized" on public.tasks;
create policy "tasks_update_authorized" on public.tasks
  for update using (
    public.is_organization_member(organization_id)
    and (
      public.is_admin(organization_id)
      or (public.is_section_head(organization_id) and team_id = public.user_team_id(organization_id))
      or assigned_to = auth.uid()
    )
  )
  with check (public.is_organization_member(organization_id));

drop policy if exists "tasks_delete_admin" on public.tasks;
create policy "tasks_delete_admin" on public.tasks
  for delete using (public.is_admin(organization_id));

-- TAGS --------------------------------------------------------------------
drop policy if exists "tags_select_member" on public.tags;
create policy "tags_select_member" on public.tags
  for select using (public.is_organization_member(organization_id));

drop policy if exists "tags_insert_admin" on public.tags;
create policy "tags_insert_admin" on public.tags
  for insert with check (public.is_admin(organization_id));

drop policy if exists "tags_update_admin" on public.tags;
create policy "tags_update_admin" on public.tags
  for update using (public.is_admin(organization_id)) with check (public.is_admin(organization_id));

drop policy if exists "tags_delete_admin" on public.tags;
create policy "tags_delete_admin" on public.tags
  for delete using (public.is_admin(organization_id));

-- TASK TAGS ---------------------------------------------------------------
drop policy if exists "task_tags_select" on public.task_tags;
create policy "task_tags_select" on public.task_tags
  for select using (public.can_access_task(task_id));

drop policy if exists "task_tags_insert" on public.task_tags;
create policy "task_tags_insert" on public.task_tags
  for insert with check (public.can_access_task(task_id));

drop policy if exists "task_tags_delete" on public.task_tags;
create policy "task_tags_delete" on public.task_tags
  for delete using (public.can_access_task(task_id));

-- TASK COMMENTS -----------------------------------------------------------
drop policy if exists "comments_select" on public.task_comments;
create policy "comments_select" on public.task_comments
  for select using (public.can_access_task(task_id));

drop policy if exists "comments_insert" on public.task_comments;
create policy "comments_insert" on public.task_comments
  for insert with check (public.can_access_task(task_id) and user_id = auth.uid());

drop policy if exists "comments_update_own_or_admin" on public.task_comments;
create policy "comments_update_own_or_admin" on public.task_comments
  for update using (user_id = auth.uid() or public.is_admin(organization_id))
  with check (user_id = auth.uid() or public.is_admin(organization_id));

drop policy if exists "comments_delete_own_or_admin" on public.task_comments;
create policy "comments_delete_own_or_admin" on public.task_comments
  for delete using (user_id = auth.uid() or public.is_admin(organization_id));

-- TASK LINKS ----------------------------------------------------------------
drop policy if exists "links_select" on public.task_links;
create policy "links_select" on public.task_links
  for select using (public.can_access_task(task_id));

drop policy if exists "links_insert" on public.task_links;
create policy "links_insert" on public.task_links
  for insert with check (public.can_access_task(task_id));

drop policy if exists "links_delete_own_or_admin" on public.task_links;
create policy "links_delete_own_or_admin" on public.task_links
  for delete using (created_by = auth.uid() or public.is_admin(organization_id));

-- TASK ATTACHMENTS ------------------------------------------------------
drop policy if exists "attachments_select" on public.task_attachments;
create policy "attachments_select" on public.task_attachments
  for select using (public.can_access_task(task_id));

drop policy if exists "attachments_insert" on public.task_attachments;
create policy "attachments_insert" on public.task_attachments
  for insert with check (public.can_access_task(task_id) and uploaded_by = auth.uid());

drop policy if exists "attachments_delete_own_or_admin" on public.task_attachments;
create policy "attachments_delete_own_or_admin" on public.task_attachments
  for delete using (uploaded_by = auth.uid() or public.is_admin(organization_id));

-- TASK ACTIVITY (immutable — no update/delete policies are defined on purpose) --------------
drop policy if exists "activity_select" on public.task_activity;
create policy "activity_select" on public.task_activity
  for select using (public.can_access_task(task_id));

drop policy if exists "activity_insert" on public.task_activity;
create policy "activity_insert" on public.task_activity
  for insert with check (public.can_access_task(task_id));

-- NOTIFICATIONS ---------------------------------------------------------
-- Rows are written by the backend using the service-role key (see project-x-api), never by clients.
drop policy if exists "notifications_select_own" on public.notifications;
create policy "notifications_select_own" on public.notifications
  for select using (user_id = auth.uid());

drop policy if exists "notifications_update_own" on public.notifications;
create policy "notifications_update_own" on public.notifications
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
