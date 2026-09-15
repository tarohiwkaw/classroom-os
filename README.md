# CLASSROOM OS V3 — REAL SYSTEM

Production-oriented classroom app: Supabase Auth, Owner/Admin/Student roles, classroom creation/join code, real database CRUD, private class files and gallery storage, community, academic management, duty, weekly, finance, attendance, feature controls, and responsive editorial UI.

## One-time setup
1. Copy `.env.example` to `.env.local` for local development, or add the same variables to Vercel:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
2. In Supabase SQL Editor, run your existing CLASSROOM OS core schema first, then run the incremental migration in `supabase/migrations/20260915_classroom_os_join.sql`.
3. Deploy. No service-role key belongs in the browser.

## Important
The app starts empty. Owner/Admin enters classroom data from the UI. Students join with a Class Code. Files use private Supabase Storage buckets.
