# CLASSROOM OS — V3

CLASSROOM OS is a classroom operating system with an identity-first onboarding flow.

## V3 flow

1. Create an account.
2. Confirm the email when Supabase requires verification.
3. Sign in.
4. Choose one of two legitimate paths:
   - **Create Classroom** → becomes `owner` automatically.
   - **Join Classroom** → enters with Class Code and becomes `student` automatically.
5. Owner/Admin can later assign `admin`, `teacher`, `treasurer`, `reporter`, `duty_manager`, or `moderator` through Members & Roles.

Users cannot self-select Admin/Owner. The UI choice controls the workflow; Supabase RPC + RLS controls actual authorization.

## Supabase

Run the core migration once, then run:

`supabase/migrations/20260915_classroom_os_v3_onboarding.sql`

Set Vercel environment variables:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

In Supabase Authentication → URL Configuration, set the production Site URL to your Vercel URL. The app also passes `window.location.origin` as the email verification redirect.

## Important

The V3 frontend still contains local-first classroom modules from the previous build while onboarding, membership, file Storage, and role operations are connected to Supabase. The relational modules are being migrated incrementally rather than pretending every module is fully real-time.
