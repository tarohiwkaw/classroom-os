# ONE-TIME DEPLOY

1. Extract this folder into the `classroom-os` repo.
2. Commit and push once.
3. Vercel will build from `main`.
4. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` to Vercel.
5. Run the SQL migration in `supabase/migrations/20260915_classroom_os_core.sql` if you want the dedicated cloud schema and private file buckets.
6. Never expose a Supabase service-role key in Vite/client code.

The UI starts empty. Admin populates class data from the web instead of editing source code.
