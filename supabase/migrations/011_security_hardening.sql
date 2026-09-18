-- 011_security_hardening.sql
-- Addresses Supabase database-linter warnings surfaced after 001-010 were applied:
--   - function_search_path_mutable (set_updated_at)
--   - extension_in_public (pg_trgm)
--   - rls_policy_always_true (organizations_insert_self — fixed directly in 009_rls.sql)
--   - anon/authenticated_security_definer_function_executable (all SECURITY DEFINER functions)
-- Safe to re-run.

-- Move pg_trgm out of the public schema into a dedicated "extensions" schema.
create schema if not exists extensions;

do $$
declare
  ext_schema text;
begin
  if not exists (select 1 from pg_extension where extname = 'pg_trgm') then
    execute 'create extension pg_trgm with schema extensions';
  else
    select n.nspname into ext_schema
    from pg_extension e
    join pg_namespace n on n.oid = e.extnamespace
    where e.extname = 'pg_trgm';

    if ext_schema <> 'extensions' then
      execute 'alter extension pg_trgm set schema extensions';
    end if;
  end if;
end;
$$;

-- Trigger-only functions are never meant to be called directly (and Postgres does not require
-- invocation privilege to fire a trigger), so revoke general EXECUTE entirely.
revoke execute on function public.set_updated_at() from public;
revoke execute on function public.handle_new_user() from public;
revoke execute on function public.handle_new_organization() from public;

-- Authorization helper functions ARE invoked as part of RLS policy evaluation for the
-- "authenticated" role, so that role must keep EXECUTE — but anon (and PUBLIC generally) does not
-- need it, since no policy in this schema grants anon access to any organization-scoped table.
revoke execute on function public.is_organization_member(uuid) from public;
grant execute on function public.is_organization_member(uuid) to authenticated;

revoke execute on function public.has_role(uuid, text[]) from public;
grant execute on function public.has_role(uuid, text[]) to authenticated;

revoke execute on function public.is_admin(uuid) from public;
grant execute on function public.is_admin(uuid) to authenticated;

revoke execute on function public.is_section_head(uuid) from public;
grant execute on function public.is_section_head(uuid) to authenticated;

revoke execute on function public.user_team_id(uuid) from public;
grant execute on function public.user_team_id(uuid) to authenticated;

revoke execute on function public.shares_organization_with(uuid) from public;
grant execute on function public.shares_organization_with(uuid) to authenticated;

revoke execute on function public.can_access_task(uuid) from public;
grant execute on function public.can_access_task(uuid) to authenticated;

revoke execute on function public.is_task_assignee(uuid) from public;
grant execute on function public.is_task_assignee(uuid) to authenticated;
