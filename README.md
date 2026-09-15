# CLASSROOM OS V1 — FULL FUNCTIONAL

A clean classroom operating system. Starts empty; Admin/Owner fills classroom data from the web UI.

## Included
Home, Class Setup, Members & Roles, Subjects, Schedule, Tasks, Exams, Calendar, Events, Announcements, Duty, Weekly, Community Channels & Chat, Study Rooms, Class Files, Gallery, Class Fund, Attendance, Class Pulse, Activity Logs, Feature Control, Settings, TH/EN.

## Run
npm install
npm run dev

## Supabase
Copy `.env.example` to `.env` and add the public project URL + anon/publishable key. Never put a service-role key in the browser.

The UI has a localStorage fallback so it can be previewed before Supabase is connected. For real shared data/files, connect the database/storage policies supplied by the project migration.
