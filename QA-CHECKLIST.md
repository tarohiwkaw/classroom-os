# CLASSROOM OS V3 QA

- [ ] New account can be created.
- [ ] Confirmation email returns to the current production origin, not localhost.
- [ ] Login does not show a fake role selector.
- [ ] A logged-in account with no classroom sees Workspace onboarding.
- [ ] Create Classroom grants Owner automatically.
- [ ] Join Classroom grants Student automatically.
- [ ] Invalid Class Code is rejected.
- [ ] Duplicate Class Code is rejected.
- [ ] Members page reads real roles from `classroom_os_members`.
- [ ] Owner can grant Admin.
- [ ] Admin cannot grant Admin to another member.
- [ ] Owner/Admin cannot change their own role through the role editor.
- [ ] Owner cannot be removed.
- [ ] Non-members cannot read classroom data through RLS.
- [ ] Class Files uses the private `class-files` bucket.
- [ ] Production Vercel build is green.
- [ ] No source file exceeds 100 MB.
