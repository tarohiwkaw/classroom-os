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

## Added after the identity/admin audit (v4)

- [ ] A student/teacher/treasurer/reporter/duty_manager/moderator action
      (e.g. checking off a task, posting in Community) is still visible
      after reloading the page.
- [ ] The same action, done on device A, is visible to a different logged-in
      user on device B after they reload.
- [ ] A non-owner/admin member cannot change classroom name/theme/features
      by any client-side means (guard trigger should reject it).
- [ ] Class Setup: change the class name, log out, log back in — the new
      name is still there (not reverted to the old one).
- [ ] Owner/Admin can remove a member from Members & Roles.
- [ ] Owner cannot be removed (button hidden; RPC also rejects it).
- [ ] "รีเฟรช" on Members & Roles picks up a member who joined mid-session.
