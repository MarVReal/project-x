-- 010_storage.sql
-- Attachment files live in Supabase Storage, never in Postgres rows. Objects must be uploaded using
-- the path convention: {organization_id}/{task_id}/{uuid}-{original_file_name}

insert into storage.buckets (id, name, public, file_size_limit)
values ('task-attachments', 'task-attachments', false, 26214400) -- 25 MB
on conflict (id) do nothing;

drop policy if exists "task_attachments_storage_select" on storage.objects;
create policy "task_attachments_storage_select" on storage.objects
  for select using (
    bucket_id = 'task-attachments'
    and public.is_organization_member((storage.foldername(name))[1]::uuid)
  );

drop policy if exists "task_attachments_storage_insert" on storage.objects;
create policy "task_attachments_storage_insert" on storage.objects
  for insert with check (
    bucket_id = 'task-attachments'
    and public.can_access_task((storage.foldername(name))[2]::uuid)
  );

drop policy if exists "task_attachments_storage_delete" on storage.objects;
create policy "task_attachments_storage_delete" on storage.objects
  for delete using (
    bucket_id = 'task-attachments'
    and (
      owner = auth.uid()
      or public.is_admin((storage.foldername(name))[1]::uuid)
    )
  );
