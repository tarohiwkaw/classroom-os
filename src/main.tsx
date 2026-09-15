import React, { useState } from 'react';
import { createRoot } from 'react-dom/client';
import {
  CalendarDays, CheckSquare, ClipboardList, Users, BookOpen, Bell,
  ChevronRight, Sparkles, Menu, X, Languages
} from 'lucide-react';
import './styles.css';

type Page =
  | 'Home' | 'Schedule' | 'Subjects' | 'Tasks' | 'Exams' | 'Calendar'
  | 'Duty Wall' | 'Events' | 'The Weekly' | 'Community' | 'Study Rooms'
  | 'Class Fund' | 'Attendance' | 'Members' | 'Class Pulse' | 'Class Moments'
  | 'Admin Center' | 'Settings';

type Lang = 'th' | 'en';

type NavItem = { p: Page; i: any; s: 'ACADEMIC' | 'CLASS' | 'COMMUNITY' | 'MANAGEMENT' };

const items: NavItem[] = [
  { p: 'Home', i: Sparkles, s: 'ACADEMIC' },
  { p: 'Schedule', i: CalendarDays, s: 'ACADEMIC' },
  { p: 'Subjects', i: BookOpen, s: 'ACADEMIC' },
  { p: 'Tasks', i: CheckSquare, s: 'ACADEMIC' },
  { p: 'Exams', i: ClipboardList, s: 'ACADEMIC' },
  { p: 'Calendar', i: CalendarDays, s: 'ACADEMIC' },
  { p: 'Duty Wall', i: ClipboardList, s: 'CLASS' },
  { p: 'Events', i: CalendarDays, s: 'CLASS' },
  { p: 'The Weekly', i: BookOpen, s: 'CLASS' },
  { p: 'Community', i: Users, s: 'COMMUNITY' },
  { p: 'Study Rooms', i: Sparkles, s: 'COMMUNITY' },
  { p: 'Class Fund', i: ClipboardList, s: 'MANAGEMENT' },
  { p: 'Attendance', i: CheckSquare, s: 'MANAGEMENT' },
  { p: 'Members', i: Users, s: 'MANAGEMENT' },
  { p: 'Class Pulse', i: Sparkles, s: 'MANAGEMENT' },
  { p: 'Class Moments', i: BookOpen, s: 'CLASS' },
  { p: 'Admin Center', i: Users, s: 'MANAGEMENT' },
  { p: 'Settings', i: ClipboardList, s: 'MANAGEMENT' }
];

const navTH: Record<Page, string> = {
  Home: 'หน้าหลัก',
  Schedule: 'ตารางเรียน',
  Subjects: 'รายวิชา',
  Tasks: 'งาน / การบ้าน',
  Exams: 'การสอบ',
  Calendar: 'ปฏิทิน',
  'Duty Wall': 'เวรประจำวัน',
  Events: 'กิจกรรม',
  'The Weekly': 'ข่าวประจำสัปดาห์',
  Community: 'ชุมชน',
  'Study Rooms': 'ห้องอ่านหนังสือ',
  'Class Fund': 'เงินห้อง',
  Attendance: 'เช็กชื่อ',
  Members: 'สมาชิก',
  'Class Pulse': 'ภาพรวมของห้อง',
  'Class Moments': 'ช่วงเวลาของห้อง',
  'Admin Center': 'ศูนย์ผู้ดูแล',
  Settings: 'ตั้งค่า'
};

const sectionTH: Record<NavItem['s'], string> = {
  ACADEMIC: 'วิชาการ',
  CLASS: 'ห้องเรียน',
  COMMUNITY: 'ชุมชน',
  MANAGEMENT: 'การจัดการ'
};

const sectionEN: Record<NavItem['s'], string> = {
  ACADEMIC: 'ACADEMIC',
  CLASS: 'CLASS',
  COMMUNITY: 'COMMUNITY',
  MANAGEMENT: 'MANAGEMENT'
};

const tasks = [
  { subject: 'เคมี', subjectEN: 'Chemistry', title: 'แบบฝึกหัดพันธะเคมี', titleEN: 'Chemical Bonding worksheet', due: 'พรุ่งนี้', dueEN: 'Tomorrow', priority: 'สูง', priorityEN: 'High' },
  { subject: 'คณิตศาสตร์', subjectEN: 'Mathematics', title: 'โจทย์ชุดที่ 7', titleEN: 'Problem set 7', due: 'พฤหัสบดี 17 ก.ย.', dueEN: 'Thu, 17 Sep', priority: 'กลาง', priorityEN: 'Medium' },
  { subject: 'ภาษาอังกฤษ', subjectEN: 'English', title: 'โครงร่างการนำเสนอ', titleEN: 'Presentation outline', due: 'ศุกร์ 18 ก.ย.', dueEN: 'Fri, 18 Sep', priority: 'ต่ำ', priorityEN: 'Low' }
];

const copy = {
  th: {
    breadcrumb: 'CLASSROOM OS / หน้าหลัก',
    classProgram: 'โครงการวิทยาศาสตร์ · 28 สมาชิก',
    editClass: 'แก้ไขห้อง',
    date: 'วันอังคาร · 15 กันยายน',
    greeting: 'สวัสดีตอนเช้า, TARO.',
    focused: 'พร้อมลุยอีกหนึ่งวัน',
    nextClass: 'คาบเรียนถัดไป',
    chemicalBonding: 'พันธะเคมี',
    room: 'ห้อง 401',
    starts: 'เริ่มใน 23 นาที',
    pulse: 'ภาพรวมของห้อง',
    studying: 'กำลังเรียน',
    activeTasks: 'งานที่กำลังทำ',
    exams: 'การสอบ',
    duties: 'เวร',
    dontForget: 'อย่าลืม',
    viewAll: 'ดูทั้งหมด',
    todaysDuty: 'เวรวันนี้',
    dutyWall: 'เวรประจำวัน',
    sweep: 'กวาดพื้นและจัดโต๊ะ',
    pending: 'รอดำเนินการ',
    broom: 'ไม้กวาดกำลังรออยู่ 👀',
    thisWeek: 'สัปดาห์นี้',
    weekRange: '15 — 20 ก.ย.',
    mon: 'จันทร์ 15',
    chemistry: 'เคมี · พันธะเคมี',
    physics: 'ฟิสิกส์ · ปฏิบัติการ',
    mathExam: 'คณิตศาสตร์ · สอบวันศุกร์',
    moduleReady: 'ส่วนนี้พร้อมสำหรับการพัฒนาขั้นต่อไป',
    visualFoundation: 'โครงสร้างหน้าจอพร้อมแล้ว',
    add: '+ เพิ่ม'
  },
  en: {
    breadcrumb: 'CLASSROOM OS / HOME',
    classProgram: 'SCIENCE PROGRAM · 28 MEMBERS',
    editClass: 'Edit Class',
    date: 'TUESDAY · 15 SEPTEMBER',
    greeting: 'GOOD MORNING, TARO.',
    focused: 'A focused day ahead.',
    nextClass: 'NEXT CLASS',
    chemicalBonding: 'Chemical Bonding',
    room: 'ROOM 401',
    starts: 'Starts in 23 min',
    pulse: 'CLASS PULSE',
    studying: 'studying',
    activeTasks: 'active tasks',
    exams: 'exams',
    duties: 'duties',
    dontForget: 'DON’T FORGET',
    viewAll: 'View all',
    todaysDuty: 'TODAY’S DUTY',
    dutyWall: 'Duty Wall',
    sweep: 'Sweep & arrange desks',
    pending: 'PENDING',
    broom: 'The broom is waiting. 👀',
    thisWeek: 'THIS WEEK',
    weekRange: '15 — 20 SEP',
    mon: 'MON 15',
    chemistry: 'Chemistry · Chemical Bonding',
    physics: 'Physics · Lab session',
    mathExam: 'Mathematics · Exam Friday',
    moduleReady: 'This module is prepared for the next implementation phase.',
    visualFoundation: 'Visual foundation is ready.',
    add: '+ Add'
  }
};

function App() {
  const [page, setPage] = useState<Page>('Home');
  const [open, setOpen] = useState(false);
  const [lang, setLang] = useState<Lang>('th');
  const t = copy[lang];
  const groups = items.reduce<Record<string, NavItem[]>>((acc, item) => {
    (acc[item.s] ??= []).push(item);
    return acc;
  }, {});

  const label = (p: Page) => lang === 'th' ? navTH[p] : p;

  return (
    <div className="app">
      <aside className={open ? 'side open' : 'side'}>
        <div className="brand">
          <b>CLASSROOM</b><span>OS</span>
          <button onClick={() => setOpen(false)} aria-label="Close menu"><X /></button>
        </div>

        <div className="classMini">
          <strong>6 / 1</strong>
          <small>{t.classProgram}</small>
        </div>

        <nav>
          {Object.entries(groups).map(([section, arr]) => (
            <div key={section}>
              <p>{lang === 'th' ? sectionTH[section as NavItem['s']] : sectionEN[section as NavItem['s']]}</p>
              {arr.map(({ p, i: I }) => (
                <button
                  className={page === p ? 'active' : ''}
                  key={p}
                  onClick={() => { setPage(p); setOpen(false); }}
                >
                  <I size={16} />
                  {label(p)}
                </button>
              ))}
            </div>
          ))}
        </nav>

        <footer>2026 · CLASSROOM OS</footer>
      </aside>

      <main>
        <header>
          <button className="menu" onClick={() => setOpen(true)} aria-label="Open menu"><Menu /></button>
          <span>{page === 'Home' ? t.breadcrumb : `CLASSROOM OS / ${label(page).toUpperCase()}`}</span>
          <div className="headerActions">
            <button
              className="langToggle"
              onClick={() => setLang(lang === 'th' ? 'en' : 'th')}
              title={lang === 'th' ? 'Switch to English' : 'เปลี่ยนเป็นภาษาไทย'}
              aria-label="Toggle language"
            >
              <Languages size={16} />
              <b>{lang === 'th' ? 'TH' : 'EN'}</b>
            </button>
            <Bell size={17} />
            <b>Taro</b>
          </div>
        </header>

        {page === 'Home'
          ? <Home setPage={setPage} lang={lang} />
          : <PageView page={page} lang={lang} />
        }
      </main>
    </div>
  );
}

function Home({ setPage, lang }: { setPage: (p: Page) => void; lang: Lang }) {
  const t = copy[lang];

  return (
    <div className="content">
      <section className="hero">
        <div className="photo" />
        <div className="shade" />
        <div className="heroText">
          <small>CLASSROOM OS · 2026</small>
          <h1>6 / 1</h1>
          <p>{t.classProgram}</p>
        </div>
        <button className="edit">{t.editClass}</button>
      </section>

      <section className="greet">
        <div>
          <small>{t.date}</small>
          <h2>{t.greeting}</h2>
        </div>
        <em>{t.focused}</em>
      </section>

      <div className="topgrid">
        <article>
          <small>{t.nextClass}</small>
          <h2>{lang === 'th' ? 'เคมี' : 'CHEMISTRY'}</h2>
          <p>{t.chemicalBonding}</p>
          <div className="meta"><b>09:00</b> {t.room} · {t.starts}</div>
        </article>

        <article>
          <small>{t.pulse}</small>
          <div className="metrics">
            <b>8<small>{t.studying}</small></b>
            <b>4<small>{t.activeTasks}</small></b>
            <b>2<small>{t.exams}</small></b>
            <b>3<small>{t.duties}</small></b>
          </div>
        </article>
      </div>

      <div className="split">
        <section>
          <div className="head">
            <h3>{t.dontForget}</h3>
            <button onClick={() => setPage('Tasks')}>{t.viewAll} <ChevronRight size={14} /></button>
          </div>
          {tasks.map((task, i) => (
            <div className="row" key={i}>
              <i />
              <div>
                <b>{lang === 'th' ? task.title : task.titleEN}</b>
                <small>{lang === 'th' ? task.subject : task.subjectEN} · {lang === 'th' ? task.due : task.dueEN}</small>
              </div>
              <label className={task.priorityEN.toLowerCase()}>{lang === 'th' ? task.priority : task.priorityEN}</label>
            </div>
          ))}
        </section>

        <section>
          <div className="head">
            <h3>{t.todaysDuty}</h3>
            <button onClick={() => setPage('Duty Wall')}>{t.dutyWall} <ChevronRight size={14} /></button>
          </div>
          <article className="duty">
            <b>{t.sweep}</b>
            <small>Taro · 08:00</small>
            <label>{t.pending}</label>
            <em>{t.broom}</em>
          </article>
        </section>
      </div>

      <section className="week">
        <div className="head">
          <h3>{t.thisWeek}</h3>
          <small>{t.weekRange}</small>
        </div>
        <div className="timeline">
          <b>{t.mon}</b>
          <span />{t.chemistry}
          <span />{t.physics}
          <span />{t.mathExam}
        </div>
      </section>
    </div>
  );
}

function PageView({ page, lang }: { page: Page; lang: Lang }) {
  const t = copy[lang];
  const title = lang === 'th' ? navTH[page] : page;

  return (
    <div className="content">
      <div className="title">
        <div>
          <small>CLASSROOM OS</small>
          <h1>{title}</h1>
          <p>6 / 1 · {lang === 'th' ? 'โครงการวิทยาศาสตร์' : 'Science Program'}</p>
        </div>
        <button>{t.add}</button>
      </div>
      <div className="empty">
        <Sparkles />
        <h2>{title}</h2>
        <p>{t.visualFoundation} {t.moduleReady}</p>
      </div>
    </div>
  );
}

createRoot(document.getElementById('root')!).render(
  <React.StrictMode><App /></React.StrictMode>
);
