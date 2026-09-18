-- 001_initial_schema.sql
-- Extensions, shared trigger helpers, organizations, profiles, organization_members, teams.

create extension if not exists pgcrypto;
create extension if not exists pg_trgm;

-- Generic "touch updated_at" trigger reused by every table below.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ORGANIZATIONS ---------------------------------------------------------
create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint organizations_name_length check (char_length(name) between 1 and 200)
);

create trigger trg_organizations_updated_at
  before update on public.organizations
  for each row execute function public.set_updated_at();

-- PROFILES ----------------------------------------------------------------
-- One row per auth.users row. Global identity only — organization/role live in organization_members.
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  full_name text not null default '',
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Auto-provision a profile row whenever a new auth user is created.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.email),
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- TEAMS / SECTIONS ----------------------------------------------------------
create table if not exists public.teams (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  name text not null,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  constraint teams_name_length check (char_length(name) between 1 and 150),
  unique (organization_id, name)
);

create index if not exists idx_teams_organization_id on public.teams (organization_id);

create trigger trg_teams_updated_at
  before update on public.teams
  for each row execute function public.set_updated_at();

-- ORGANIZATION MEMBERS ---------------------------------------------------
-- Links a profile to an organization with a role/team/status. Supports future multi-org membership.
create table if not exists public.organization_members (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  team_id uuid references public.teams (id) on delete set null,
  role text not null default 'staff' check (role in ('admin', 'section_head', 'staff')),
  status text not null default 'invited' check (status in ('invited', 'active', 'inactive')),
  invited_by uuid references public.profiles (id) on delete set null,
  invited_at timestamptz not null default now(),
  joined_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (organization_id, user_id)
);

create index if not exists idx_org_members_organization_id on public.organization_members (organization_id);
create index if not exists idx_org_members_user_id on public.organization_members (user_id);
create index if not exists idx_org_members_team_id on public.organization_members (team_id);

create trigger trg_org_members_updated_at
  before update on public.organization_members
  for each row execute function public.set_updated_at();

-- When a user creates a new organization, automatically make them its admin member.
create or replace function public.handle_new_organization()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.organization_members (organization_id, user_id, role, status, joined_at)
  values (new.id, auth.uid(), 'admin', 'active', now())
  on conflict (organization_id, user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_organization_created on public.organizations;
create trigger on_organization_created
  after insert on public.organizations
  for each row execute function public.handle_new_organization();
