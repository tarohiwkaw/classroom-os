-- CLASSROOM OS incremental migration
-- Run after the core schema migration.

create or replace function public.classroom_os_join_by_code(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  c public.classroom_os_classrooms%rowtype;
  m public.classroom_os_members%rowtype;
  display text;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;
  select * into c from public.classroom_os_classrooms
  where upper(class_code)=upper(trim(p_code)) limit 1;
  if c.id is null then raise exception 'class_not_found'; end if;
  display := coalesce(auth.jwt()->'user_metadata'->>'display_name', split_part(coalesce(auth.email(),''),'@',1), 'Student');
  insert into public.classroom_os_members(classroom_id,user_id,display_name,role,status)
  values(c.id,auth.uid(),display,'student','active')
  on conflict(classroom_id,user_id) do update set status='active';
  select * into m from public.classroom_os_members where classroom_id=c.id and user_id=auth.uid();
  return jsonb_build_object('classroom_id',c.id,'role',m.role,'display_name',m.display_name,'classroom',to_jsonb(c));
end;
$$;
revoke all on function public.classroom_os_join_by_code(text) from public, anon;
grant execute on function public.classroom_os_join_by_code(text) to authenticated;

create or replace function public.classroom_os_create_classroom(
  p_name text,p_program text,p_year text,p_code text,p_description text default ''
)
returns jsonb
language plpgsql
security definer
set search_path=public
as $$
declare c public.classroom_os_classrooms%rowtype;
begin
 if auth.uid() is null then raise exception 'not_authenticated'; end if;
 if length(trim(p_name))<1 or length(trim(p_code))<3 then raise exception 'invalid_classroom'; end if;
 insert into public.classroom_os_classrooms(name,program,academic_year,class_code,description,created_by)
 values(trim(p_name),trim(p_program),trim(p_year),upper(trim(p_code)),coalesce(p_description,''),auth.uid()) returning * into c;
 insert into public.classroom_os_members(classroom_id,user_id,display_name,role,status)
 values(c.id,auth.uid(),coalesce(auth.jwt()->'user_metadata'->>'display_name',split_part(coalesce(auth.email(),''),'@',1),'Owner'),'owner','active');
 insert into public.classroom_os_feature_settings(classroom_id) values(c.id);
 return jsonb_build_object('classroom',to_jsonb(c));
exception when unique_violation then raise exception 'class_code_taken';
end;
$$;
revoke all on function public.classroom_os_create_classroom(text,text,text,text,text) from public,anon;
grant execute on function public.classroom_os_create_classroom(text,text,text,text,text) to authenticated;

create or replace function public.classroom_os_ensure_default_channels(p_classroom_id uuid)
returns void language plpgsql security definer set search_path=public as $$
begin
 if not public.classroom_os_is_admin(p_classroom_id) then raise exception 'forbidden'; end if;
 insert into public.classroom_os_channels(classroom_id,name,description) values
 (p_classroom_id,'general','พูดคุยทั่วไป'),
 (p_classroom_id,'homework','งานและการบ้าน'),
 (p_classroom_id,'exam','ข่าวสอบ'),
 (p_classroom_id,'study','อ่านหนังสือด้วยกัน') on conflict do nothing;
end;$$;
revoke all on function public.classroom_os_ensure_default_channels(uuid) from public,anon;
grant execute on function public.classroom_os_ensure_default_channels(uuid) to authenticated;
