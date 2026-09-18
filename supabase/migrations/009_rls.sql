-- 009_rls.sql
-- Enables Row Level Security on every table and defines policies using the helper functions from
-- 008_helper_functions.sql. This is the real authorization boundary — Angular guards are UX only.

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
create policy "organizations_select_member" on public.organizations
  for select using (public.is_organization_member(id));

create policy "organizations_insert_self" on public.organizations
  for insert with check (true); -- creator is auto-added as admin via on_organization_created trigger

create policy "organizations_update_admin" on public.organizations
  for update using (public.is_admin(id)) with check (public.is_admin(id));

-- PROFILES --------------------------------------------------------------
create policy "profiles_select_self_or_org" on public.profiles
  for select using (id = auth.uid() or public.shares_organization_with(id));

create policy "profiles_update_self" on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

-- TEAMS -------------------------------------------------------------------
create policy "teams_select_member" on public.teams
  for select using (public.is_organization_member(organization_id));

create policy "teams_manage_admin" on public.teams
  for insert with check (public.is_admin(organization_id));

create policy "teams_update_admin" on public.teams
  for update using (public.is_admin(organization_id)) with check (public.is_admin(organization_id));

create policy "teams_delete_admin" on public.teams
  for delete using (public.is_admin(organization_id));

-- ORGANIZATION MEMBERS ----------------------------------------------------
create policy "org_members_select_member" on public.organization_members
  for select using (public.is_organization_member(organization_id));

create policy "org_members_insert_admin" on public.organization_members
  for insert with check (public.is_admin(organization_id));

create policy "org_members_update_admin_or_self" on public.organization_members
  for update using (public.is_admin(organization_id) or user_id = auth.uid())
  with check (public.is_admin(organization_id) or user_id = auth.uid());

create policy "org_members_delete_admin" on public.organization_members
  for delete using (public.is_admin(organization_id));

-- PIPELINES -----------------------------------------------------------------
create policy "pipelines_select_member" on public.pipelines
  for select using (public.is_organization_member(organization_id));

create policy "pipelines_insert_admin" on public.pipelines
  for insert with check (public.is_admin(organization_id));

create policy "pipelines_update_admin" on public.pipelines
  for update using (public.is_admin(organization_id)) with check (public.is_admin(organization_id));

create policy "pipelines_delete_admin" on public.pipelines
  for delete using (public.is_admin(organization_id));

-- PIPELINE STAGES -------------------------------------------------------
create policy "stages_select_member" on public.pipeline_stages
  for select using (public.is_organization_member(organization_id));

create policy "stages_insert_admin" on public.pipeline_stages
  for insert with check (public.is_admin(organization_id));

create policy "stages_update_admin" on public.pipeline_stages
  for update using (public.is_admin(organization_id)) with check (public.is_admin(organization_id));

create policy "stages_delete_admin" on public.pipeline_stages
  for delete using (public.is_admin(organization_id));

-- TASKS -----------------------------------------------------------------
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

create policy "tasks_insert_admin_or_section_head" on public.tasks
  for insert with check (public.is_section_head(organization_id));

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

create policy "tasks_delete_admin" on public.tasks
  for delete using (public.is_admin(organization_id));

-- TAGS --------------------------------------------------------------------
create policy "tags_select_member" on public.tags
  for select using (public.is_organization_member(organization_id));

create policy "tags_insert_admin" on public.tags
  for insert with check (public.is_admin(organization_id));

create policy "tags_update_admin" on public.tags
  for update using (public.is_admin(organization_id)) with check (public.is_admin(organization_id));

create policy "tags_delete_admin" on public.tags
  for delete using (public.is_admin(organization_id));

-- TASK TAGS ---------------------------------------------------------------
create policy "task_tags_select" on public.task_tags
  for select using (public.can_access_task(task_id));

create policy "task_tags_insert" on public.task_tags
  for insert with check (public.can_access_task(task_id));

create policy "task_tags_delete" on public.task_tags
  for delete using (public.can_access_task(task_id));

-- TASK COMMENTS -----------------------------------------------------------
create policy "comments_select" on public.task_comments
  for select using (public.can_access_task(task_id));

create policy "comments_insert" on public.task_comments
  for insert with check (public.can_access_task(task_id) and user_id = auth.uid());

create policy "comments_update_own_or_admin" on public.task_comments
  for update using (user_id = auth.uid() or public.is_admin(organization_id))
  with check (user_id = auth.uid() or public.is_admin(organization_id));

create policy "comments_delete_own_or_admin" on public.task_comments
  for delete using (user_id = auth.uid() or public.is_admin(organization_id));

-- TASK LINKS ----------------------------------------------------------------
create policy "links_select" on public.task_links
  for select using (public.can_access_task(task_id));

create policy "links_insert" on public.task_links
  for insert with check (public.can_access_task(task_id));

create policy "links_delete_own_or_admin" on public.task_links
  for delete using (created_by = auth.uid() or public.is_admin(organization_id));

-- TASK ATTACHMENTS ------------------------------------------------------
create policy "attachments_select" on public.task_attachments
  for select using (public.can_access_task(task_id));

create policy "attachments_insert" on public.task_attachments
  for insert with check (public.can_access_task(task_id) and uploaded_by = auth.uid());

create policy "attachments_delete_own_or_admin" on public.task_attachments
  for delete using (uploaded_by = auth.uid() or public.is_admin(organization_id));

-- TASK ACTIVITY (immutable — no update/delete policies are defined on purpose) --------------
create policy "activity_select" on public.task_activity
  for select using (public.can_access_task(task_id));

create policy "activity_insert" on public.task_activity
  for insert with check (public.can_access_task(task_id));

-- NOTIFICATIONS ---------------------------------------------------------
-- Rows are written by the backend using the service-role key (see project-x-api), never by clients.
create policy "notifications_select_own" on public.notifications
  for select using (user_id = auth.uid());

create policy "notifications_update_own" on public.notifications
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
