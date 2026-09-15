-- CLASSROOM OS core schema.
-- Run once in the Supabase SQL editor for a real multi-user deployment.
create extension if not exists pgcrypto;

create table if not exists public.classroom_os_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Student',
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.classroom_os_classrooms (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  program text not null default '',
  academic_year text not null default '',
  code text not null unique,
  description text not null default '',
  cover_url text,
  logo_url text,
  theme text not null default 'sage',
  humor_mode text not null default 'off',
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.classroom_os_members (
  classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null default 'Student',
  roles text[] not null default array['student']::text[],
  active boolean not null default true,
  joined_at timestamptz not null default now(),
  primary key (classroom_id,user_id)
);

create table if not exists public.classroom_os_subjects (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  name text not null, code text not null default '', teacher text not null default '', color text not null default 'sage', created_at timestamptz not null default now()
);
create table if not exists public.classroom_os_schedule (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  subject_id uuid references public.classroom_os_subjects(id) on delete set null, day text not null, start_time time not null, end_time time not null, room text not null default '', created_at timestamptz not null default now()
);
create table if not exists public.classroom_os_tasks (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  subject_id uuid references public.classroom_os_subjects(id) on delete set null, title text not null, description text not null default '', due_at timestamptz, priority text not null default 'normal', created_by uuid not null references auth.users(id) on delete cascade, created_at timestamptz not null default now()
);
create table if not exists public.classroom_os_exams (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  subject_id uuid references public.classroom_os_subjects(id) on delete set null, title text not null, exam_at timestamptz not null, room text not null default '', topics text not null default '', created_by uuid not null references auth.users(id) on delete cascade, created_at timestamptz not null default now()
);
create table if not exists public.classroom_os_events (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  title text not null, description text not null default '', starts_at timestamptz not null, location text not null default '', created_by uuid not null references auth.users(id) on delete cascade, created_at timestamptz not null default now()
);
create table if not exists public.classroom_os_announcements (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  title text not null, body text not null, pinned boolean not null default false, created_by uuid not null references auth.users(id) on delete cascade, created_at timestamptz not null default now()
);
create table if not exists public.classroom_os_duties (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  duty_date date not null, title text not null, assignee_id uuid references auth.users(id) on delete set null, status text not null default 'pending', note text not null default '', created_by uuid not null references auth.users(id) on delete cascade, created_at timestamptz not null default now()
);
create table if not exists public.classroom_os_channels (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  name text not null, type text not null default 'chat', created_at timestamptz not null default now()
);
create table if not exists public.classroom_os_messages (
  id uuid primary key default gen_random_uuid(), channel_id uuid not null references public.classroom_os_channels(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade, content text not null, reply_to uuid references public.classroom_os_messages(id) on delete set null, created_at timestamptz not null default now()
);
create table if not exists public.classroom_os_files (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  uploaded_by uuid not null references auth.users(id) on delete cascade, name text not null, storage_path text not null unique, mime_type text not null default 'application/octet-stream', size_bytes bigint not null default 0, category text not null default 'เอกสาร', description text not null default '', created_at timestamptz not null default now()
);
create table if not exists public.classroom_os_file_downloads (
  id uuid primary key default gen_random_uuid(), file_id uuid not null references public.classroom_os_files(id) on delete cascade, user_id uuid not null references auth.users(id) on delete cascade, downloaded_at timestamptz not null default now()
);
create table if not exists public.classroom_os_rooms (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  name text not null, subject text not null default '', topic text not null default '', active boolean not null default true, created_by uuid not null references auth.users(id) on delete cascade, created_at timestamptz not null default now()
);
create table if not exists public.classroom_os_transactions (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  type text not null check(type in ('income','expense')), amount numeric(12,2) not null check(amount>=0), title text not null, note text not null default '', occurred_at timestamptz not null default now(), created_by uuid not null references auth.users(id) on delete cascade
);
create table if not exists public.classroom_os_attendance_sessions (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  title text not null, session_at timestamptz not null default now(), qr_token text not null unique, created_by uuid not null references auth.users(id) on delete cascade
);
create table if not exists public.classroom_os_attendance (
  session_id uuid not null references public.classroom_os_attendance_sessions(id) on delete cascade, user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'present', marked_at timestamptz not null default now(), primary key(session_id,user_id)
);
create table if not exists public.classroom_os_gallery (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  uploaded_by uuid not null references auth.users(id) on delete cascade, storage_path text, image_url text, caption text not null default '', album text not null default 'Class Moments', created_at timestamptz not null default now()
);
create table if not exists public.classroom_os_weekly (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  title text not null default 'THE CLASSROOM WEEKLY', body text not null, author_id uuid not null references auth.users(id) on delete cascade, published_at timestamptz not null default now()
);
create table if not exists public.classroom_os_activity (
  id uuid primary key default gen_random_uuid(), classroom_id uuid not null references public.classroom_os_classrooms(id) on delete cascade,
  user_id uuid references auth.users(id) on delete set null, action text not null, entity text not null, metadata jsonb not null default '{}'::jsonb, created_at timestamptz not null default now()
);

create or replace function public.classroom_os_is_member(cid uuid)
returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.classroom_os_members m where m.classroom_id=cid and m.user_id=auth.uid() and m.active=true);
$$;
create or replace function public.classroom_os_has_role(cid uuid, needed text[])
returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.classroom_os_members m where m.classroom_id=cid and m.user_id=auth.uid() and m.active=true and m.roles && needed);
$$;
revoke all on function public.classroom_os_is_member(uuid) from public;
revoke all on function public.classroom_os_has_role(uuid,text[]) from public;
grant execute on function public.classroom_os_is_member(uuid) to authenticated;
grant execute on function public.classroom_os_has_role(uuid,text[]) to authenticated;

alter table public.classroom_os_profiles enable row level security;
alter table public.classroom_os_classrooms enable row level security;
alter table public.classroom_os_members enable row level security;
alter table public.classroom_os_subjects enable row level security;
alter table public.classroom_os_schedule enable row level security;
alter table public.classroom_os_tasks enable row level security;
alter table public.classroom_os_exams enable row level security;
alter table public.classroom_os_events enable row level security;
alter table public.classroom_os_announcements enable row level security;
alter table public.classroom_os_duties enable row level security;
alter table public.classroom_os_channels enable row level security;
alter table public.classroom_os_messages enable row level security;
alter table public.classroom_os_files enable row level security;
alter table public.classroom_os_file_downloads enable row level security;
alter table public.classroom_os_rooms enable row level security;
alter table public.classroom_os_transactions enable row level security;
alter table public.classroom_os_attendance_sessions enable row level security;
alter table public.classroom_os_attendance enable row level security;
alter table public.classroom_os_gallery enable row level security;
alter table public.classroom_os_weekly enable row level security;
alter table public.classroom_os_activity enable row level security;

-- Generic member read policies. Writes should be done through server-side role checks or matching owner/admin policies in production.
drop policy if exists profile_self on public.classroom_os_profiles;
create policy profile_self on public.classroom_os_profiles for all to authenticated using(id=auth.uid()) with check(id=auth.uid());
drop policy if exists classroom_member_read on public.classroom_os_classrooms;
create policy classroom_member_read on public.classroom_os_classrooms for select to authenticated using(public.classroom_os_is_member(id) or created_by=auth.uid());
drop policy if exists member_read on public.classroom_os_members;
create policy member_read on public.classroom_os_members for select to authenticated using(public.classroom_os_is_member(classroom_id) or user_id=auth.uid());
drop policy if exists subjects_member_read on public.classroom_os_subjects;
create policy subjects_member_read on public.classroom_os_subjects for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists schedule_member_read on public.classroom_os_schedule;
create policy schedule_member_read on public.classroom_os_schedule for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists tasks_member_read on public.classroom_os_tasks;
create policy tasks_member_read on public.classroom_os_tasks for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists exams_member_read on public.classroom_os_exams;
create policy exams_member_read on public.classroom_os_exams for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists events_member_read on public.classroom_os_events;
create policy events_member_read on public.classroom_os_events for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists announcements_member_read on public.classroom_os_announcements;
create policy announcements_member_read on public.classroom_os_announcements for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists duties_member_read on public.classroom_os_duties;
create policy duties_member_read on public.classroom_os_duties for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists channels_member_read on public.classroom_os_channels;
create policy channels_member_read on public.classroom_os_channels for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists messages_member_read on public.classroom_os_messages;
create policy messages_member_read on public.classroom_os_messages for select to authenticated using(exists(select 1 from public.classroom_os_channels c where c.id=channel_id and public.classroom_os_is_member(c.classroom_id)));
drop policy if exists files_member_read on public.classroom_os_files;
create policy files_member_read on public.classroom_os_files for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists file_download_self on public.classroom_os_file_downloads;
create policy file_download_self on public.classroom_os_file_downloads for all to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid());
drop policy if exists rooms_member_read on public.classroom_os_rooms;
create policy rooms_member_read on public.classroom_os_rooms for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists transactions_member_read on public.classroom_os_transactions;
create policy transactions_member_read on public.classroom_os_transactions for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists attendance_member_read on public.classroom_os_attendance;
create policy attendance_member_read on public.classroom_os_attendance for select to authenticated using(user_id=auth.uid() or exists(select 1 from public.classroom_os_attendance_sessions s where s.id=session_id and public.classroom_os_has_role(s.classroom_id,array['owner','admin','teacher'])));
drop policy if exists gallery_member_read on public.classroom_os_gallery;
create policy gallery_member_read on public.classroom_os_gallery for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists weekly_member_read on public.classroom_os_weekly;
create policy weekly_member_read on public.classroom_os_weekly for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists activity_admin_read on public.classroom_os_activity;
create policy activity_admin_read on public.classroom_os_activity for select to authenticated using(public.classroom_os_has_role(classroom_id,array['owner','admin']));

insert into storage.buckets(id,name,public,file_size_limit) values ('class-files','class-files',false,52428800) on conflict(id) do nothing;
insert into storage.buckets(id,name,public,file_size_limit) values ('class-gallery','class-gallery',false,104857600) on conflict(id) do nothing;
drop policy if exists classroom_os_storage_files_select on storage.objects;
create policy classroom_os_storage_files_select on storage.objects for select to authenticated using(bucket_id='class-files' and public.classroom_os_is_member(((storage.foldername(name))[1])::uuid));
drop policy if exists classroom_os_storage_files_insert on storage.objects;
create policy classroom_os_storage_files_insert on storage.objects for insert to authenticated with check(bucket_id='class-files' and public.classroom_os_is_member(((storage.foldername(name))[1])::uuid));
drop policy if exists classroom_os_storage_files_delete on storage.objects;
create policy classroom_os_storage_files_delete on storage.objects for delete to authenticated using(bucket_id='class-files' and owner_id=auth.uid()::text);
drop policy if exists classroom_os_storage_gallery_select on storage.objects;
create policy classroom_os_storage_gallery_select on storage.objects for select to authenticated using(bucket_id='class-gallery' and public.classroom_os_is_member(((storage.foldername(name))[1])::uuid));
drop policy if exists classroom_os_storage_gallery_insert on storage.objects;
create policy classroom_os_storage_gallery_insert on storage.objects for insert to authenticated with check(bucket_id='class-gallery' and public.classroom_os_is_member(((storage.foldername(name))[1])::uuid));
drop policy if exists classroom_os_storage_gallery_delete on storage.objects;
create policy classroom_os_storage_gallery_delete on storage.objects for delete to authenticated using(bucket_id='class-gallery' and owner_id=auth.uid()::text);

-- V1 application snapshot: keeps the complete classroom UI state cloud-persistent while the relational modules are being adopted incrementally.
create table if not exists public.classroom_os_state (
  classroom_id uuid primary key references public.classroom_os_classrooms(id) on delete cascade,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.classroom_os_state enable row level security;
drop policy if exists classroom_os_state_read on public.classroom_os_state;
create policy classroom_os_state_read on public.classroom_os_state for select to authenticated using(public.classroom_os_is_member(classroom_id));
drop policy if exists classroom_os_state_write on public.classroom_os_state;
create policy classroom_os_state_write on public.classroom_os_state for insert to authenticated with check(public.classroom_os_has_role(classroom_id,array['owner','admin']));
drop policy if exists classroom_os_state_update on public.classroom_os_state;
create policy classroom_os_state_update on public.classroom_os_state for update to authenticated using(public.classroom_os_has_role(classroom_id,array['owner','admin'])) with check(public.classroom_os_has_role(classroom_id,array['owner','admin']));
