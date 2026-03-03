import { CaseItem, CourtHoliday, DiaryEntry, HelpRequest, ReminderItem } from "./types";

// ─── ID generator ─────────────────────────────────────────────────────────────
export const makeId = () => `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`;
const makeRef = () => {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  const suffix = Array.from({ length: 6 }, () => chars[Math.floor(Math.random() * chars.length)]).join("");
  return `LH-${new Date().getFullYear()}-${suffix}`;
};

// ─── Cases (seeded) ───────────────────────────────────────────────────────────
export const cases: CaseItem[] = [
  {
    id: "case-001",
    caseNumber: "LL-2025-DEMO001",
    title: "Rajan vs State of Delhi",
    caseType: "Criminal",
    clientName: "Ramesh Rajan",
    clientPhone: "9811000001",
    opposingParty: "State of Delhi",
    courtName: "Delhi High Court",
    courtType: "High Court",
    judgeOrBench: "Hon. Justice A.K. Sharma",
    filedDate: "2025-11-10",
    nextHearingDate: "2026-03-15",
    status: "in_progress",
    advocateId: "test-user-001",
    notes: "Case proceeding well. Bail secured. Next hearing on 15 March.",
    timeline: [
      { date: "2025-11-10", event: "FIR filed and case registered", status: "done" },
      { date: "2025-11-22", event: "Bail application filed", status: "done" },
      { date: "2025-12-05", event: "Bail granted by Sessions Court", status: "done" },
      { date: "2026-01-20", event: "First hearing — arguments submitted", status: "done" },
      { date: "2026-02-10", event: "Documents submitted to court", status: "done" },
      { date: "2026-03-15", event: "Next hearing (scheduled)", status: "upcoming" },
      { date: "TBD", event: "Final arguments", status: "pending" },
      { date: "TBD", event: "Judgement", status: "pending" },
    ],
    createdAt: "2025-11-10T09:00:00.000Z",
    updatedAt: "2026-02-10T14:00:00.000Z",
  },
  {
    id: "case-002",
    caseNumber: "LL-2025-DEMO002",
    title: "Sharma vs Gupta (Property Dispute)",
    caseType: "Civil",
    clientName: "Amit Sharma",
    clientPhone: "9123456789",
    opposingParty: "Rajiv Gupta",
    courtName: "Delhi High Court",
    courtType: "High Court",
    judgeOrBench: "Hon. Justice P.S. Nair",
    filedDate: "2025-09-01",
    nextHearingDate: "2026-04-10",
    status: "open",
    advocateId: "test-user-001",
    notes: "Property partition suit. Survey report pending.",
    timeline: [
      { date: "2025-09-01", event: "Suit filed", status: "done" },
      { date: "2025-10-15", event: "Notice issued to defendant", status: "done" },
      { date: "2025-12-20", event: "Written statement filed by defendant", status: "done" },
      { date: "2026-04-10", event: "Issues to be framed", status: "upcoming" },
      { date: "TBD", event: "Evidence stage", status: "pending" },
      { date: "TBD", event: "Final arguments", status: "pending" },
    ],
    createdAt: "2025-09-01T10:00:00.000Z",
    updatedAt: "2025-12-20T16:00:00.000Z",
  },
  {
    id: "case-003",
    caseNumber: "LL-2026-DEMO003",
    title: "Meera Nair vs Arun Nair (Divorce)",
    caseType: "Family",
    clientName: "Meera Nair",
    clientPhone: "9922000001",
    opposingParty: "Arun Nair",
    courtName: "Family Court, Delhi",
    courtType: "Family Court",
    judgeOrBench: "Hon. Judge R. Khanna",
    filedDate: "2026-01-05",
    nextHearingDate: "2026-03-25",
    status: "open",
    advocateId: "test-user-001",
    notes: "Mutual consent divorce petition. Cooling period ongoing.",
    timeline: [
      { date: "2026-01-05", event: "Petition filed under Section 13-B HMA", status: "done" },
      { date: "2026-01-20", event: "First motion granted", status: "done" },
      { date: "2026-03-25", event: "Second motion hearing (after 6-month cooling period)", status: "upcoming" },
      { date: "TBD", event: "Decree of divorce", status: "pending" },
    ],
    createdAt: "2026-01-05T10:00:00.000Z",
    updatedAt: "2026-01-20T11:00:00.000Z",
  },
];

// ─── Reminders ────────────────────────────────────────────────────────────────
export const reminders: ReminderItem[] = [
  {
    id: "rem-001",
    caseId: "case-001",
    title: "Prepare cross-examination questions for Rajan vs State",
    dueDate: "2026-03-10",
    priority: "high",
    isCompleted: false,
    createdAt: "2026-02-15T10:00:00.000Z",
  },
  {
    id: "rem-002",
    caseId: "case-002",
    title: "Collect survey report for Sharma property dispute",
    dueDate: "2026-03-30",
    priority: "medium",
    isCompleted: false,
    createdAt: "2026-02-20T10:00:00.000Z",
  },
];

// ─── Diary entries ─────────────────────────────────────────────────────────────
export const diaryEntries: DiaryEntry[] = [
  {
    id: "diary-001",
    date: "2026-03-02",
    title: "Client meeting — Ramesh Rajan",
    notes: "Discussed strategy for next hearing. Client confident. Reviewed bail conditions.",
    category: "meeting",
    linkedCaseId: "case-001",
    createdAt: "2026-03-02T09:00:00.000Z",
  },
];

// ─── Help requests ────────────────────────────────────────────────────────────
export const helpRequests: HelpRequest[] = [];

export const addHelpRequest = (req: Omit<HelpRequest, "id" | "refNumber" | "createdAt" | "status">): HelpRequest => {
  const newReq: HelpRequest = {
    ...req,
    id: makeId(),
    refNumber: makeRef(),
    status: "pending",
    createdAt: new Date().toISOString(),
  };
  helpRequests.push(newReq);
  return newReq;
};

// ─── Court Holidays 2025-2026 ─────────────────────────────────────────────────
// Covers: National holidays, Summer/Winter vacation, Court-specific closures
export const courtHolidays: CourtHoliday[] = [
  // ── National holidays (all courts closed) ───────────────────────────────────
  { id: "h-001", date: "2026-01-01", title: "New Year's Day", type: "national", courts: ["all"], year: 2026 },
  { id: "h-002", date: "2026-01-14", title: "Makar Sankranti / Pongal", type: "national", courts: ["all"], year: 2026 },
  { id: "h-003", date: "2026-01-26", title: "Republic Day", type: "national", courts: ["all"], year: 2026, description: "National holiday — courts closed across India." },
  { id: "h-004", date: "2026-02-18", title: "Maha Shivratri", type: "national", courts: ["all"], year: 2026 },
  { id: "h-005", date: "2026-03-25", title: "Holi", type: "national", courts: ["all"], year: 2026 },
  { id: "h-006", date: "2026-03-30", title: "Shri Ram Navami", type: "national", courts: ["all"], year: 2026 },
  { id: "h-007", date: "2026-04-02", title: "Mahavir Jayanti", type: "national", courts: ["all"], year: 2026 },
  { id: "h-008", date: "2026-04-03", title: "Good Friday", type: "national", courts: ["all"], year: 2026 },
  { id: "h-009", date: "2026-04-14", title: "Dr. Ambedkar Jayanti", type: "national", courts: ["all"], year: 2026 },
  { id: "h-010", date: "2026-05-01", title: "Labour Day (Maharashtra / Tamil Nadu)", type: "gazetted", courts: ["bombay_hc", "madras_hc"], year: 2026 },
  { id: "h-011", date: "2026-05-22", title: "Buddha Purnima", type: "national", courts: ["all"], year: 2026 },
  { id: "h-012", date: "2026-06-17", title: "Eid ul-Adha", type: "national", courts: ["all"], year: 2026 },
  { id: "h-013", date: "2026-07-07", title: "Muharram", type: "national", courts: ["all"], year: 2026 },
  { id: "h-014", date: "2026-08-15", title: "Independence Day", type: "national", courts: ["all"], year: 2026, description: "National holiday — courts closed across India." },
  { id: "h-015", date: "2026-08-26", title: "Janmashtami", type: "national", courts: ["all"], year: 2026 },
  { id: "h-016", date: "2026-09-16", title: "Milad-un-Nabi", type: "national", courts: ["all"], year: 2026 },
  { id: "h-017", date: "2026-10-02", title: "Gandhi Jayanti / Dussehra", type: "national", courts: ["all"], year: 2026 },
  { id: "h-018", date: "2026-10-20", title: "Diwali (Deepawali)", type: "national", courts: ["all"], year: 2026 },
  { id: "h-019", date: "2026-10-21", title: "Diwali (2nd day)", type: "national", courts: ["all"], year: 2026 },
  { id: "h-020", date: "2026-11-04", title: "Guru Nanak Jayanti", type: "national", courts: ["all"], year: 2026 },
  { id: "h-021", date: "2026-11-19", title: "Chhath Puja", type: "gazetted", courts: ["all"], year: 2026 },
  { id: "h-022", date: "2026-12-25", title: "Christmas Day", type: "national", courts: ["all"], year: 2026 },
  // ── 2025 holidays (for backward compat) ────────────────────────────────────
  { id: "h-101", date: "2025-01-26", title: "Republic Day", type: "national", courts: ["all"], year: 2025 },
  { id: "h-102", date: "2025-03-14", title: "Holi", type: "national", courts: ["all"], year: 2025 },
  { id: "h-103", date: "2025-04-10", title: "Mahavir Jayanti", type: "national", courts: ["all"], year: 2025 },
  { id: "h-104", date: "2025-04-18", title: "Good Friday", type: "national", courts: ["all"], year: 2025 },
  { id: "h-105", date: "2025-08-15", title: "Independence Day", type: "national", courts: ["all"], year: 2025 },
  { id: "h-106", date: "2025-10-02", title: "Gandhi Jayanti", type: "national", courts: ["all"], year: 2025 },
  { id: "h-107", date: "2025-10-20", title: "Diwali", type: "national", courts: ["all"], year: 2025 },
  { id: "h-108", date: "2025-12-25", title: "Christmas Day", type: "national", courts: ["all"], year: 2025 },
  // ── Supreme Court specific ──────────────────────────────────────────────────
  { id: "sc-001", date: "2026-05-09", title: "Supreme Court Summer Vacation begins", type: "court_vacation", courts: ["supreme_court"], year: 2026, description: "Supreme Court Summer Vacation 2026 (9 May – 7 June). Vacation benches operate for urgent matters." },
  { id: "sc-002", date: "2026-05-10", title: "Supreme Court Summer Vacation", type: "court_vacation", courts: ["supreme_court"], year: 2026 },
  { id: "sc-003", date: "2026-05-11", title: "Supreme Court Summer Vacation", type: "court_vacation", courts: ["supreme_court"], year: 2026 },
  { id: "sc-004", date: "2026-05-12", title: "Supreme Court Summer Vacation", type: "court_vacation", courts: ["supreme_court"], year: 2026 },
  { id: "sc-005", date: "2026-05-13", title: "Supreme Court Summer Vacation", type: "court_vacation", courts: ["supreme_court"], year: 2026 },
  { id: "sc-006", date: "2026-06-06", title: "Supreme Court Summer Vacation ends", type: "court_vacation", courts: ["supreme_court"], year: 2026 },
  { id: "sc-007", date: "2026-12-20", title: "Supreme Court Winter Vacation begins", type: "court_vacation", courts: ["supreme_court"], year: 2026, description: "Supreme Court Winter Vacation 2026 (20 Dec – 4 Jan 2027)." },
  { id: "sc-008", date: "2026-12-21", title: "Supreme Court Winter Vacation", type: "court_vacation", courts: ["supreme_court"], year: 2026 },
  { id: "sc-009", date: "2026-12-22", title: "Supreme Court Winter Vacation", type: "court_vacation", courts: ["supreme_court"], year: 2026 },
  { id: "sc-010", date: "2026-12-23", title: "Supreme Court Winter Vacation", type: "court_vacation", courts: ["supreme_court"], year: 2026 },
  // ── Delhi HC specific ───────────────────────────────────────────────────────
  { id: "dhc-001", date: "2026-05-16", title: "Delhi HC Summer Vacation begins", type: "court_vacation", courts: ["delhi_hc"], year: 2026, description: "Delhi High Court Summer Vacation (16 May – 14 June)." },
  { id: "dhc-002", date: "2026-05-17", title: "Delhi HC Summer Vacation", type: "court_vacation", courts: ["delhi_hc"], year: 2026 },
  { id: "dhc-003", date: "2026-05-18", title: "Delhi HC Summer Vacation", type: "court_vacation", courts: ["delhi_hc"], year: 2026 },
  { id: "dhc-004", date: "2026-06-14", title: "Delhi HC Summer Vacation ends", type: "court_vacation", courts: ["delhi_hc"], year: 2026 },
  { id: "dhc-005", date: "2026-12-25", title: "Delhi HC Winter Vacation begins", type: "court_vacation", courts: ["delhi_hc"], year: 2026 },
  { id: "dhc-006", date: "2026-04-06", title: "Delhi HC Closed (Ram Navami special sitting cancelled)", type: "court_specific", courts: ["delhi_hc"], year: 2026 },
  // ── Bombay HC specific ──────────────────────────────────────────────────────
  { id: "bhc-001", date: "2026-05-02", title: "Bombay HC Summer Vacation begins", type: "court_vacation", courts: ["bombay_hc"], year: 2026, description: "Bombay High Court Summer Vacation (2 May – 31 May)." },
  { id: "bhc-002", date: "2026-05-31", title: "Bombay HC Summer Vacation ends", type: "court_vacation", courts: ["bombay_hc"], year: 2026 },
  { id: "bhc-003", date: "2026-09-02", title: "Ganesh Chaturthi (Bombay HC closed)", type: "court_specific", courts: ["bombay_hc"], year: 2026 },
  // ── Allahabad HC ────────────────────────────────────────────────────────────
  { id: "ahc-001", date: "2026-05-01", title: "Allahabad HC Summer Vacation", type: "court_vacation", courts: ["allahabad_hc"], year: 2026 },
  { id: "ahc-002", date: "2026-10-24", title: "Govardhan Puja (Allahabad HC)", type: "court_specific", courts: ["allahabad_hc"], year: 2026 },
  // ── Madras HC ───────────────────────────────────────────────────────────────
  { id: "mhc-001", date: "2026-04-14", title: "Tamil New Year (Madras HC)", type: "court_specific", courts: ["madras_hc"], year: 2026 },
  { id: "mhc-002", date: "2026-01-15", title: "Pongal (Madras HC)", type: "court_specific", courts: ["madras_hc"], year: 2026 },
  // ── Calcutta HC ─────────────────────────────────────────────────────────────
  { id: "chc-001", date: "2026-10-19", title: "Kali Puja / Diwali (Calcutta HC)", type: "court_specific", courts: ["calcutta_hc"], year: 2026 },
  { id: "chc-002", date: "2026-10-05", title: "Maha Ashtami (Calcutta HC)", type: "court_specific", courts: ["calcutta_hc"], year: 2026 },
  // ── Kerala HC ───────────────────────────────────────────────────────────────
  { id: "khc-001", date: "2026-08-29", title: "Onam (Kerala HC)", type: "court_specific", courts: ["kerala_hc"], year: 2026 },
  { id: "khc-002", date: "2026-08-30", title: "Onam second day (Kerala HC)", type: "court_specific", courts: ["kerala_hc"], year: 2026 },
  // ── Karnataka HC ────────────────────────────────────────────────────────────
  { id: "karhc-001", date: "2026-11-01", title: "Kannada Rajyotsava (Karnataka HC)", type: "court_specific", courts: ["karnataka_hc"], year: 2026 },
];

