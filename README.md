# CLASSROOM OS — V1 Complete Build

A bright editorial classroom operating system designed around an empty-first classroom: admins populate real class data; students consume and contribute.

## Included UX
- Student + Owner/Admin login flows
- Supabase Auth when env vars exist; safe local demo mode when they do not
- Empty-first Home, Schedule, Subjects, Tasks, Exams, Calendar
- Events, Announcements, Duty Wall, Weekly editorial
- Community channels + chat
- Study Rooms + focus timer
- Class Files with upload/download flow and private Supabase Storage support
- Class Moments gallery with image URL decoration
- Class Fund
- Attendance session / QR foundation
- Members & multi-role UI
- Class Pulse analytics from real local state
- Activity Logs
- Admin Control Center, Setup Checklist, Feature Control, Settings
- Themes: sage / sand / sky / lavender / terracotta
- Optional Classroom Humor Mode: off / friendly / chaos
- Responsive desktop / iPad / mobile layout

## Run
npm install
npm run dev

## Verify build
npm run build

## Supabase
Copy `.env.example` to `.env` and set:
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=

Run `supabase/migrations/20260915_classroom_os_core.sql` once for the dedicated CLASSROOM OS schema. It intentionally uses `classroom_os_*` table names so existing DISCIPLINE tables are not overwritten.

For production, use Supabase Auth + RLS. Never put a service-role key in the browser. The local demo login is for UI testing only and is not a security boundary.

## Admin bootstrap
After the first real Supabase account is created, an existing owner/admin should assign the account to a classroom in `classroom_os_members` with roles such as `owner` or `admin`. Do not make all users admins.
