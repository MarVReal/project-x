-- 008_helper_functions.sql
-- Reusable, security-definer helper functions so authorization SQL is written once and reused by every
-- RLS policy. All are STABLE and SECURITY DEFINER so they can read organization_members without
-- being blocked by that table's own RLS (which would otherwise cause recursive-policy errors).

create or replace function public.is_organization_member(p_organization_id uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.organization_members
    where organization_id = p_organization_id
      and user_id = auth.uid()
      and status = 'active'
  );
$$;

create or replace function public.has_role(p_organization_id uuid, p_roles text[])
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.organization_members
    where organization_id = p_organization_id
      and user_id = auth.uid()
      and status = 'active'
      and role = any(p_roles)
  );
$$;

create or replace function public.is_admin(p_organization_id uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select public.has_role(p_organization_id, array['admin']);
$$;

create or replace function public.is_section_head(p_organization_id uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select public.has_role(p_organization_id, array['admin', 'section_head']);
$$;

create or replace function public.user_team_id(p_organization_id uuid)
returns uuid
language sql stable security definer set search_path = public
as $$
  select team_id from public.organization_members
  where organization_id = p_organization_id
    and user_id = auth.uid()
    and status = 'active'
  limit 1;
$$;

create or replace function public.shares_organization_with(p_user_id uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1
    from public.organization_members mine
    join public.organization_members theirs
      on theirs.organization_id = mine.organization_id
    where mine.user_id = auth.uid()
      and mine.status = 'active'
      and theirs.user_id = p_user_id
      and theirs.status = 'active'
  );
$$;

-- Centralizes the "can this user see/act on this task" rule shared by comments, links, attachments,
-- tags, and activity so it never has to be duplicated across policies.
create or replace function public.can_access_task(p_task_id uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.tasks t
    where t.id = p_task_id
      and public.is_organization_member(t.organization_id)
      and (
        public.is_admin(t.organization_id)
        or (public.is_section_head(t.organization_id) and t.team_id = public.user_team_id(t.organization_id))
        or t.assigned_to = auth.uid()
        or t.created_by = auth.uid()
      )
  );
$$;

create or replace function public.is_task_assignee(p_task_id uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.tasks where id = p_task_id and assigned_to = auth.uid()
  );
$$;
