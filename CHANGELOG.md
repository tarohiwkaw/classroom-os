# CHANGELOG — identity/admin audit fix pass

## Fixed

**Critical — non-owner/admin roles never persisted to Supabase.**
`src/main.tsx` had a cloud-save effect gated with
`can(user, ["owner","admin"])`; combined with matching RLS on
`classroom_os_state`, this meant teacher/treasurer/reporter/duty_manager/
moderator/student actions only ever lived in the acting user's own
browser and vanished on reload or for anyone else. Fixed in both places:
- `supabase/migrations/20260915_classroom_os_v4_state_fix.sql` — write
  policies now check membership, not role.
- `src/main.tsx` — the save effect now fires for any signed-in member.
- Added a `before update` trigger (`classroom_os_guard_state_update`) so
  opening up writes doesn't let a non-admin client rewrite classroom
  identity or feature flags — those two sub-keys inside the shared blob
  stay owner/admin-only. Actual role authorization was never read from
  this blob (always `classroom_os_members` / `classroom_os_has_role`), so
  this is defense-in-depth, not a change to how permissions are decided.

**Class Setup edits could get silently reverted.** `classroom_os_classrooms`
was only ever read, never written, so a saved name/theme/program change
(which only landed in the state blob) could be clobbered back to the old
table row on the next login, depending on merge order. `src/main.tsx` now
prefers the freshly-loaded state blob's `classroom` object over the
possibly-stale table snapshot. Also added an UPDATE policy on
`classroom_os_classrooms` (owner/admin) so the table can be kept in sync
going forward.

**Member removal had no UI.** `classroom_os_remove_member` existed and was
correctly guarded server-side (owner cannot be removed, admin cannot
remove another admin/owner) but no button called it. Added a "นำออก"
action to Members & Roles, gated the same way role-editing already was.

**Members list went stale.** It was fetched once per login; a member who
joined mid-session wouldn't appear for others until they signed out and
back in. Added a manual "รีเฟรช" button on the Members & Roles page.

## Verified, not changed

- `npm run build` (tsc + vite) is green.
- Role-edit RPC (`classroom_os_set_member_roles`) correctly blocks
  self-edits, editing an owner, and non-owners granting admin.
- Auth screen has no fake role selector; Create → owner, Join → student.
- `class-files` / `class-gallery` storage buckets are private with
  per-classroom-member policies.

## Recommended next (not done in this pass)

The migration created 13 feature-specific tables (`classroom_os_tasks`,
`_exams`, `_events`, `_announcements`, `_duties`, `_messages`, `_files`,
`_rooms`, `_transactions`, `_attendance*`, `_gallery`, `_weekly`,
`_activity`) with read-only RLS — the client never writes to any of them.
Every feature instead lives inside the one JSONB blob this pass just
reopened for writing. That's fine functionally now, but it means:
- No per-row RLS (a moderator can technically touch class-fund data
  inside the blob, since the boundary is "classroom member", not
  "message" vs. "transaction").
- No realtime subscriptions — Community chat, Duty, attendance, etc. only
  update when the whole blob round-trips.
- Last-write-wins on the entire snapshot, so two people editing different
  modules within the same ~650ms window can clobber each other.

Migrating each module to its real table (the schema already exists) with
per-feature RLS matching the existing client-side `canWrite` rules would
fix all three, but it's a genuine rewrite of ~12 page components' data
layer, not a patch — worth planning as its own pass rather than rushing
into the current codebase.
