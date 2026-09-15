# CLASSROOM OS QA CHECKLIST

## Build / code hygiene
- [x] TypeScript source checked with a dependency shim in this environment.
- [x] No generated `node_modules`, build output, secrets, or giant source file included.
- [x] `src/main.tsx` is normal source size; previous 289 MB issue is not present.
- [ ] Run `npm install && npm run build` in CI/Vercel after upload (this environment cannot reach npm reliably).

## Auth UX
- [x] Student / Member mode.
- [x] Admin / Owner mode in Local Demo.
- [x] Supabase Auth email/password path.
- [x] Session hydration on refresh.
- [x] Remote role lookup from `classroom_members` / `classroom_os_members`.
- [x] Sign out.
- [x] Join-by-Class-Code flow in Local Mode.

## Student workflows
- [x] View Home.
- [x] View schedule/tasks/exams/calendar.
- [x] Complete/uncomplete tasks.
- [x] Chat in community.
- [x] Enter study room and run focus timer.
- [x] Upload/download class files when Supabase Storage is configured.
- [x] Add class moments by image URL.

## Admin workflows
- [x] Admin Control Center.
- [x] Setup checklist.
- [x] Class identity/theme/cover/logo fields.
- [x] Members + multi-role UI.
- [x] Subjects.
- [x] Schedule.
- [x] Tasks.
- [x] Exams.
- [x] Events.
- [x] Announcements.
- [x] Duty Wall.
- [x] Weekly editorial.
- [x] Channels.
- [x] Study Rooms.
- [x] Class Fund.
- [x] Attendance session foundation.
- [x] Class Files.
- [x] Gallery.
- [x] Feature Control.
- [x] Activity Logs.

## Data / security
- [x] Local-first state is namespaced under `classroom-os-v2`.
- [x] No service-role key in frontend.
- [x] Dedicated Supabase migration uses `classroom_os_*` names to avoid overwriting DISCIPLINE tables.
- [x] Private Storage buckets are defined in migration.
- [x] RLS read policies are included.
- [ ] Production data CRUD synchronization for every module should be wired before calling the system a fully cloud-persistent release. The current build is intentionally safe to test locally first.
