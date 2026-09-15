# Deploy CLASSROOM OS V3

1. Replace the project in Working Copy with this V3 package.
2. Commit: `feat: redesign V3 identity-first onboarding`
3. Push `main`.
4. Vercel builds automatically.
5. Confirm Vercel env vars: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`.
6. Supabase → Authentication → URL Configuration → Site URL = production Vercel URL.
7. Run the V3 onboarding SQL migration once.

### Test order

Account → email confirmation → sign in → Create Classroom → verify Owner → open Members & Roles → join from a second account with Class Code → verify Student → Owner assigns Teacher/Admin → verify the second account sees the correct role.
