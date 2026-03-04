// ─── Case ────────────────────────────────────────────────────────────────────
export type CaseStatus = "open" | "in_progress" | "adjourned" | "decided" | "closed";

export interface CaseTimelineEvent {
  date: string;
  event: string;
  status: "done" | "upcoming" | "pending";
  addedBy?: string;
}

export interface CaseItem {
  id: string;
  caseNumber: string;
  title: string;
  caseType: string;
  clientName: string;
  clientPhone?: string;
  opposingParty?: string;
  courtName: string;
  courtType: string;
  judgeOrBench?: string;
  nextHearingDate?: string;
  filedDate: string;
  status: CaseStatus;
  advocateId?: string;
  notes?: string;
  timeline: CaseTimelineEvent[];
  createdAt: string;
  updatedAt: string;
}

// ─── Reminder ─────────────────────────────────────────────────────────────────
export interface ReminderItem {
  id: string;
  caseId?: string;
  title: string;
  dueDate: string;
  priority: "low" | "medium" | "high";
  isCompleted: boolean;
  createdAt: string;
}

// ─── Diary ────────────────────────────────────────────────────────────────────
export interface DiaryEntry {
  id: string;
  date: string;
  title: string;
  notes: string;
  category: "hearing" | "meeting" | "filing" | "research" | "other";
  linkedCaseId?: string;
  createdAt: string;
}

// ─── Calendar / Holidays ──────────────────────────────────────────────────────
export type HolidayType =
  | "national"
  | "court_vacation"
  | "court_specific"
  | "gazetted"
  | "restricted";

export type CourtScope =
  | "all"
  | "supreme_court"
  | "delhi_hc"
  | "bombay_hc"
  | "madras_hc"
  | "calcutta_hc"
  | "karnataka_hc"
  | "allahabad_hc"
  | "gujarat_hc"
  | "kerala_hc"
  | "punjab_hc"
  | "rajasthan_hc"
  | "mp_hc"
  | "patna_hc"
  | "hyderabad_hc";

// Vacation range – expanded to individual days in the API
export interface CourtVacation {
  id: string;
  name: string;
  startDate: string;
  endDate: string;
  courts: CourtScope[];
  year: number;
  description?: string;
}

export interface CourtHoliday {
  id: string;
  date: string;
  title: string;
  description?: string;
  type: HolidayType;
  courts: CourtScope[];
  year: number;
}

// ─── Client Help Request ──────────────────────────────────────────────────────
export interface HelpRequest {
  id: string;
  refNumber: string;
  fullName: string;
  mobile: string;
  description: string;
  category: string;
  preferredCourt: string;
  contactPreference: string;
  status: "pending" | "assigned" | "resolved";
  assignedAdvocateId?: string;
  createdAt: string;
}

// ─── Tracked Case (public) ────────────────────────────────────────────────────
export interface TrackedCase {
  id: string;
  title: string;
  caseType: string;
  status: string;
  court: string;
  advocate: string;
  clientName: string;
  filedDate: string;
  nextHearing: string;
  timeline: CaseTimelineEvent[];
  notes?: string;
}
