-- CLASSROOM OS V3 ONBOARDING / IDENTITY
-- Run AFTER 20260915_classroom_os_core.sql.
-- This migration fixes the identity flow: account first, then create/join a classroom.

create or replace function public.classroom_os_create_classroom(
  p_name text,
  p_program text,
  p_year text,
  p_code text,
  p_description text default ''
)
returns jsonb
language plpgsql
security definer
set search_path=public
as $$
declare
  c public.classroom_os_classrooms%rowtype;
  display text;
begin
  if auth.uid() is null then raise exception 'not_authenticated'; end if;
  if nullif(trim(p_name),'') is null then raise exception 'invalid_classroom_name'; end if;
  if length(trim(p_code)) < 4 then raise exception 'invalid_class_code'; end if;

  insert into public.classroom_os_classrooms(name,program,academic_year,code,description,created_by)
  values(trim(p_name),coalesce(trim(p_program),''),coalesce(trim(p_year),''),upper(regexp_replace(trim(p_code),'\s','','g')),coalesce(trim(p_description),''),auth.uid())
  returning * into c;

  display := coalesce(auth.jwt()->'user_metadata'->>'display_name', split_part(coalesce(auth.email(),''),'@',1), 'Owner');
  insert into public.classroom_os_members(classroom_id,user_id,display_name,roles,active)
  values(c.id,auth.uid(),display,array['owner']::text[],true);

  insert into public.classroom_os_channels(classroom_id,name,type)
  values(c.id,'general','chat'),(c.id,'homework','chat'),(c.id,'exam','chat'),(c.id,'study','chat')
  on conflict do nothing;

  return jsonb_build_object('classroom_id',c.id,'code',c.code,'role','owner');
exception when unique_violation then
  raise exception 'class_code_taken';
end;
$$;

revoke all on function public.classroom_os_create_classroom(text,text,text,text,text) from public, anon;
grant execute on function public.classroom_os_create_classroom(text,text,text,text,text) to authenticated;

create or replace function public.classroom_os_join_by_code(p_code text)
returns jsonb
language plpgsql
security definer
set search_path=public
as $$
declare
  c public.classroom_os_classrooms%rowtype;
  display text;
begin
  if auth.uid() is null then raise exception 'not_authenticated'; end if;
  select * into c from public.classroom_os_classrooms where code=upper(regexp_replace(trim(p_code),'\s','','g')) limit 1;
  if c.id is null then raise exception 'class_not_found'; end if;

  display := coalesce(auth.jwt()->'user_metadata'->>'display_name', split_part(coalesce(auth.email(),''),'@',1), 'Student');
  insert into public.classroom_os_members(classroom_id,user_id,display_name,roles,active)
  values(c.id,auth.uid(),display,array['student']::text[],true)
  on conflict(classroom_id,user_id) do update set active=true;

  return jsonb_build_object('classroom_id',c.id,'code',c.code,'role','student');
end;
$$;

revoke all on function public.classroom_os_join_by_code(text) from public, anon;
grant execute on function public.classroom_os_join_by_code(text) to authenticated;

create or replace function public.classroom_os_set_member_roles(
  p_classroom_id uuid,
  p_user_id uuid,
  p_roles text[]
)
returns jsonb
language plpgsql
security definer
set search_path=public
as $$
declare
  actor_roles text[];
  target_roles text[];
  clean_roles text[];
begin
  if auth.uid() is null then raise exception 'not_authenticated'; end if;
  if p_user_id=auth.uid() then raise exception 'cannot_edit_self'; end if;

  select roles into actor_roles from public.classroom_os_members
  where classroom_id=p_classroom_id and user_id=auth.uid() and active=true;
  if actor_roles is null or not (actor_roles && array['owner','admin']::text[]) then raise exception 'forbidden'; end if;

  select roles into target_roles from public.classroom_os_members
  where classroom_id=p_classroom_id and user_id=p_user_id and active=true;
  if target_roles is null then raise exception 'member_not_found'; end if;
  if target_roles @> array['owner']::text[] then raise exception 'cannot_edit_owner'; end if;

  select coalesce(array_agg(distinct x order by x),'{}') into clean_roles
  from unnest(p_roles) x
  where x in ('student','teacher','treasurer','reporter','duty_manager','moderator','admin');
  if clean_roles='{}' then raise exception 'invalid_roles'; end if;

  if not (actor_roles && array['owner']::text[]) and clean_roles && array['admin']::text[] then
    raise exception 'only_owner_can_grant_admin';
  end if;

  update public.classroom_os_members set roles=clean_roles where classroom_id=p_classroom_id and user_id=p_user_id;
  return jsonb_build_object('user_id',p_user_id,'roles',clean_roles);
end;
$$;

revoke all on function public.classroom_os_set_member_roles(uuid,uuid,text[]) from public, anon;
grant execute on function public.classroom_os_set_member_roles(uuid,uuid,text[]) to authenticated;

create or replace function public.classroom_os_remove_member(p_classroom_id uuid,p_user_id uuid)
returns void
language plpgsql
security definer
set search_path=public
as $$
declare actor_roles text[]; target_roles text[];
begin
  select roles into actor_roles from public.classroom_os_members where classroom_id=p_classroom_id and user_id=auth.uid() and active=true;
  select roles into target_roles from public.classroom_os_members where classroom_id=p_classroom_id and user_id=p_user_id and active=true;
  if actor_roles is null or not (actor_roles && array['owner','admin']::text[]) then raise exception 'forbidden'; end if;
  if target_roles && array['owner','admin']::text[] and not (actor_roles && array['owner']::text[]) then raise exception 'forbidden'; end if;
  update public.classroom_os_members set active=false where classroom_id=p_classroom_id and user_id=p_user_id and not (roles @> array['owner']::text[]);
end;
$$;
revoke all on function public.classroom_os_remove_member(uuid,uuid) from public, anon;
grant execute on function public.classroom_os_remove_member(uuid,uuid) to authenticated;
