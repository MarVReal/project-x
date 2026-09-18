-- supabase/seed.sql
-- LOCAL DEVELOPMENT ONLY. Runs automatically after `supabase db reset` (Supabase CLI).
-- Do NOT run this against a hosted/production project — it inserts test auth users with a known
-- password purely so the app is usable immediately after local setup (see section 31 of the spec).

-- Demo users -----------------------------------------------------------------
-- Password for all three accounts: Password123!
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, email_change, email_change_token_new, recovery_token
) values
  ('00000000-0000-0000-0000-000000000000', '11111111-1111-1111-1111-111111111111', 'authenticated', 'authenticated',
   'admin@demo.local', crypt('Password123!', gen_salt('bf')), now(), now(),
   '{"provider":"email","providers":["email"]}', '{"full_name":"Demo Admin"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', '22222222-2222-2222-2222-222222222222', 'authenticated', 'authenticated',
   'sectionhead@demo.local', crypt('Password123!', gen_salt('bf')), now(), now(),
   '{"provider":"email","providers":["email"]}', '{"full_name":"Demo Section Head"}', now(), now(), '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', '33333333-3333-3333-3333-333333333333', 'authenticated', 'authenticated',
   'staff@demo.local', crypt('Password123!', gen_salt('bf')), now(), now(),
   '{"provider":"email","providers":["email"]}', '{"full_name":"Demo Staff"}', now(), now(), '', '', '', '')
on conflict (id) do nothing;
-- The on_auth_user_created trigger (see 001_initial_schema.sql) auto-creates matching public.profiles rows.

-- Demo organization -----------------------------------------------------
insert into public.organizations (id, name, slug)
values ('99999999-9999-9999-9999-999999999999', 'Demo Organization', 'demo-organization')
on conflict (id) do nothing;

-- Demo team ---------------------------------------------------------------
insert into public.teams (id, organization_id, name, description)
values ('88888888-8888-8888-8888-888888888888', '99999999-9999-9999-9999-999999999999', 'General', 'Default section')
on conflict (id) do nothing;

-- Organization membership (roles) ----------------------------------------
insert into public.organization_members (organization_id, user_id, team_id, role, status, joined_at)
values
  ('99999999-9999-9999-9999-999999999999', '11111111-1111-1111-1111-111111111111', '88888888-8888-8888-8888-888888888888', 'admin', 'active', now()),
  ('99999999-9999-9999-9999-999999999999', '22222222-2222-2222-2222-222222222222', '88888888-8888-8888-8888-888888888888', 'section_head', 'active', now()),
  ('99999999-9999-9999-9999-999999999999', '33333333-3333-3333-3333-333333333333', '88888888-8888-8888-8888-888888888888', 'staff', 'active', now())
on conflict (organization_id, user_id) do nothing;

-- Pipelines + stages -------------------------------------------------------
insert into public.pipelines (id, organization_id, name, description, color, icon, created_by)
values
  ('a1111111-1111-1111-1111-111111111111', '99999999-9999-9999-9999-999999999999', 'Marketing', 'Marketing campaigns and content', '#8E24AA', 'campaign', '11111111-1111-1111-1111-111111111111'),
  ('a2222222-2222-2222-2222-222222222222', '99999999-9999-9999-9999-999999999999', 'IT Support', 'Internal IT support requests', '#1E88E5', 'support_agent', '11111111-1111-1111-1111-111111111111'),
  ('a3333333-3333-3333-3333-333333333333', '99999999-9999-9999-9999-999999999999', 'General Tasks', 'Miscellaneous organization tasks', '#43A047', 'task_alt', '11111111-1111-1111-1111-111111111111')
on conflict (id) do nothing;

insert into public.pipeline_stages (id, organization_id, pipeline_id, name, position, is_completed, color)
values
  -- Marketing
  ('b1000001-0000-0000-0000-000000000001', '99999999-9999-9999-9999-999999999999', 'a1111111-1111-1111-1111-111111111111', 'Idea', 0, false, '#B39DDB'),
  ('b1000002-0000-0000-0000-000000000002', '99999999-9999-9999-9999-999999999999', 'a1111111-1111-1111-1111-111111111111', 'Planning', 1, false, '#9575CD'),
  ('b1000003-0000-0000-0000-000000000003', '99999999-9999-9999-9999-999999999999', 'a1111111-1111-1111-1111-111111111111', 'Production', 2, false, '#7E57C2'),
  ('b1000004-0000-0000-0000-000000000004', '99999999-9999-9999-9999-999999999999', 'a1111111-1111-1111-1111-111111111111', 'Review', 3, false, '#673AB7'),
  ('b1000005-0000-0000-0000-000000000005', '99999999-9999-9999-9999-999999999999', 'a1111111-1111-1111-1111-111111111111', 'Published', 4, true, '#5E35B1'),
  -- IT Support
  ('b2000001-0000-0000-0000-000000000001', '99999999-9999-9999-9999-999999999999', 'a2222222-2222-2222-2222-222222222222', 'New', 0, false, '#90CAF9'),
  ('b2000002-0000-0000-0000-000000000002', '99999999-9999-9999-9999-999999999999', 'a2222222-2222-2222-2222-222222222222', 'Information Needed', 1, false, '#64B5F6'),
  ('b2000003-0000-0000-0000-000000000003', '99999999-9999-9999-9999-999999999999', 'a2222222-2222-2222-2222-222222222222', 'In Progress', 2, false, '#42A5F5'),
  ('b2000004-0000-0000-0000-000000000004', '99999999-9999-9999-9999-999999999999', 'a2222222-2222-2222-2222-222222222222', 'Waiting', 3, false, '#2196F3'),
  ('b2000005-0000-0000-0000-000000000005', '99999999-9999-9999-9999-999999999999', 'a2222222-2222-2222-2222-222222222222', 'Completed', 4, true, '#1E88E5'),
  -- General Tasks
  ('b3000001-0000-0000-0000-000000000001', '99999999-9999-9999-9999-999999999999', 'a3333333-3333-3333-3333-333333333333', 'New', 0, false, '#A5D6A7'),
  ('b3000002-0000-0000-0000-000000000002', '99999999-9999-9999-9999-999999999999', 'a3333333-3333-3333-3333-333333333333', 'In Progress', 1, false, '#81C784'),
  ('b3000003-0000-0000-0000-000000000003', '99999999-9999-9999-9999-999999999999', 'a3333333-3333-3333-3333-333333333333', 'Completed', 2, true, '#66BB6A')
on conflict (id) do nothing;

-- Tags ----------------------------------------------------------------------
insert into public.tags (id, organization_id, name, color, created_by)
values
  ('c1000001-0000-0000-0000-000000000001', '99999999-9999-9999-9999-999999999999', 'Urgent', '#E53935', '11111111-1111-1111-1111-111111111111'),
  ('c1000002-0000-0000-0000-000000000002', '99999999-9999-9999-9999-999999999999', 'Internal', '#546E7A', '11111111-1111-1111-1111-111111111111'),
  ('c1000003-0000-0000-0000-000000000003', '99999999-9999-9999-9999-999999999999', 'Marketing', '#8E24AA', '11111111-1111-1111-1111-111111111111'),
  ('c1000004-0000-0000-0000-000000000004', '99999999-9999-9999-9999-999999999999', 'Development', '#3949AB', '11111111-1111-1111-1111-111111111111'),
  ('c1000005-0000-0000-0000-000000000005', '99999999-9999-9999-9999-999999999999', 'Client', '#00897B', '11111111-1111-1111-1111-111111111111')
on conflict (id) do nothing;

-- Sample tasks ----------------------------------------------------------
insert into public.tasks (
  id, organization_id, pipeline_id, stage_id, team_id, title, description, priority,
  start_date, due_date, assigned_to, created_by
) values
  ('d1000001-0000-0000-0000-000000000001', '99999999-9999-9999-9999-999999999999',
   'a1111111-1111-1111-1111-111111111111', 'b1000002-0000-0000-0000-000000000002',
   '88888888-8888-8888-8888-888888888888', 'Draft Q4 social media plan',
   'Outline campaign themes and posting cadence for Q4.', 'high',
   current_date, now() + interval '5 days', '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111'),
  ('d1000002-0000-0000-0000-000000000002', '99999999-9999-9999-9999-999999999999',
   'a2222222-2222-2222-2222-222222222222', 'b2000001-0000-0000-0000-000000000001',
   '88888888-8888-8888-8888-888888888888', 'Laptop replacement request',
   'Staff laptop is failing to boot; needs replacement.', 'urgent',
   current_date, now() + interval '1 day', '33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222'),
  ('d1000003-0000-0000-0000-000000000003', '99999999-9999-9999-9999-999999999999',
   'a3333333-3333-3333-3333-333333333333', 'b3000001-0000-0000-0000-000000000001',
   '88888888-8888-8888-8888-888888888888', 'Update employee handbook',
   'Review and update PTO policy section.', 'medium',
   null, now() + interval '14 days', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111')
on conflict (id) do nothing;

insert into public.task_tags (task_id, tag_id, organization_id)
values
  ('d1000001-0000-0000-0000-000000000001', 'c1000003-0000-0000-0000-000000000003', '99999999-9999-9999-9999-999999999999'),
  ('d1000002-0000-0000-0000-000000000002', 'c1000001-0000-0000-0000-000000000001', '99999999-9999-9999-9999-999999999999'),
  ('d1000003-0000-0000-0000-000000000003', 'c1000002-0000-0000-0000-000000000002', '99999999-9999-9999-9999-999999999999')
on conflict do nothing;
