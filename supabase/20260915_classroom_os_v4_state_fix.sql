-- CLASSROOM OS V4 — FIX: cloud state was writable by owner/admin only.
-- Root cause: classroom_os_state is a single JSONB snapshot per classroom
-- that almost every module (tasks, exams, events, announcements, duty,
-- messages, files list, gallery, class fund, attendance, weekly) writes
-- through. Its RLS policies only allowed owner/admin to insert/update it,
-- so every other role's actions were silently lost after leaving the tab.
-- Run this AFTER 20260915_classroom_os_v3_onboarding.sql.

-- 1) Any ACTIVE MEMBER of the classroom may now write the shared state,
--    not just owner/admin. Membership (not role) is the write boundary —
--    matches what the UI already expects for teacher/treasurer/reporter/
--    duty_manager/moderator/student actions.
drop policy if exists classroom_os_state_write on public.classroom_os_state;
create policy classroom_os_state_write on public.classroom_os_state
  for insert to authenticated
  with check (public.classroom_os_is_member(classroom_id));

drop policy if exists classroom_os_state_update on public.classroom_os_state;
create policy classroom_os_state_update on public.classroom_os_state
  for update to authenticated
  using (public.classroom_os_is_member(classroom_id))
  with check (public.classroom_os_is_member(classroom_id));

-- 2) Because the whole classroom lives in one JSONB blob, opening writes
--    to every member means a compromised/malicious student client could
--    otherwise rewrite classroom identity or feature flags. This trigger
--    keeps those two sub-keys owner/admin-only even though the rest of
--    the blob is now shared-write. (Roles themselves are never read from
--    this blob for authorization — classroom_os_members / classroom_os_has_role
--    is always the source of truth — so this is a defense-in-depth guard,
--    not the only thing standing between a student and admin powers.)
create or replace function public.classroom_os_guard_state_update()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if (old.state -> 'classroom') is distinct from (new.state -> 'classroom')
     or (old.state -> 'features') is distinct from (new.state -> 'features') then
    if not public.classroom_os_has_role(new.classroom_id, array['owner','admin']) then
      raise exception 'forbidden_classroom_settings_change';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists classroom_os_state_guard on public.classroom_os_state;
create trigger classroom_os_state_guard
  before update on public.classroom_os_state
  for each row execute function public.classroom_os_guard_state_update();

-- 3) classroom_os_classrooms had no UPDATE policy at all (Class Setup only
--    ever wrote the JSONB copy, which — see onboarding fix in app code —
--    was also getting clobbered back to stale values on next login). This
--    makes the real table editable by owner/admin so the source-of-truth
--    row can be kept in sync going forward.
drop policy if exists classroom_owner_admin_update on public.classroom_os_classrooms;
create policy classroom_owner_admin_update on public.classroom_os_classrooms
  for update to authenticated
  using (public.classroom_os_has_role(id, array['owner','admin']))
  with check (public.classroom_os_has_role(id, array['owner','admin']));
