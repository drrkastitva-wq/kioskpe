import { CaseItem, CourtHoliday, CourtVacation, DiaryEntry, HelpRequest, ReminderItem } from "./types";

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
  // ── NATIONAL HOLIDAYS 2026 (all courts closed) ────────────────────────────
  { id: "n-001", date: "2026-01-01", title: "New Year's Day", type: "national", courts: ["all"], year: 2026 },
  { id: "n-002", date: "2026-01-14", title: "Makar Sankranti / Pongal / Uttarayan", type: "national", courts: ["all"], year: 2026, description: "Harvesting festival. Pongal in Tamil Nadu, Uttarayan in Gujarat, Makar Sankranti across North India." },
  { id: "n-003", date: "2026-01-26", title: "Republic Day", type: "national", courts: ["all"], year: 2026, description: "National holiday — all courts closed across India." },
  { id: "n-004", date: "2026-02-18", title: "Maha Shivratri", type: "national", courts: ["all"], year: 2026 },
  { id: "n-005", date: "2026-03-03", title: "Holi (Holika Dahan/Dhulendi)", type: "national", courts: ["all"], year: 2026, description: "Festival of colours. Date may vary by state." },
  { id: "n-006", date: "2026-03-25", title: "Ram Navami", type: "national", courts: ["all"], year: 2026 },
  { id: "n-007", date: "2026-04-02", title: "Mahavir Jayanti", type: "national", courts: ["all"], year: 2026 },
  { id: "n-008", date: "2026-04-03", title: "Good Friday", type: "national", courts: ["all"], year: 2026 },
  { id: "n-009", date: "2026-04-14", title: "Dr. B.R. Ambedkar Jayanti", type: "national", courts: ["all"], year: 2026, description: "National holiday. Also observed as Tamil Puthandu (New Year) in Tamil Nadu and Vishu in Kerala." },
  { id: "n-010", date: "2026-05-22", title: "Buddha Purnima", type: "national", courts: ["all"], year: 2026 },
  { id: "n-011", date: "2026-06-17", title: "Eid ul-Adha (Bakrid)", type: "national", courts: ["all"], year: 2026, description: "Date subject to moon sighting. Approximate." },
  { id: "n-012", date: "2026-07-07", title: "Muharram", type: "national", courts: ["all"], year: 2026, description: "Islamic New Year. Date subject to moon sighting." },
  { id: "n-013", date: "2026-08-15", title: "Independence Day", type: "national", courts: ["all"], year: 2026, description: "National holiday — all courts closed." },
  { id: "n-014", date: "2026-08-26", title: "Janmashtami", type: "national", courts: ["all"], year: 2026 },
  { id: "n-015", date: "2026-09-05", title: "Eid-e-Milad (Prophet's Birthday)", type: "national", courts: ["all"], year: 2026, description: "Date subject to moon sighting. Approximate." },
  { id: "n-016", date: "2026-10-02", title: "Gandhi Jayanti", type: "national", courts: ["all"], year: 2026 },
  { id: "n-017", date: "2026-10-20", title: "Diwali (Deepawali)", type: "national", courts: ["all"], year: 2026 },
  { id: "n-018", date: "2026-10-21", title: "Diwali — 2nd day / Govardhan Puja", type: "national", courts: ["all"], year: 2026 },
  { id: "n-019", date: "2026-11-04", title: "Guru Nanak Jayanti (Gurpurab)", type: "national", courts: ["all"], year: 2026 },
  { id: "n-020", date: "2026-12-25", title: "Christmas Day", type: "national", courts: ["all"], year: 2026 },

  // ── NATIONAL HOLIDAYS 2025 (backward compat) ──────────────────────────────
  { id: "n25-001", date: "2025-01-26", title: "Republic Day", type: "national", courts: ["all"], year: 2025 },
  { id: "n25-002", date: "2025-03-14", title: "Holi", type: "national", courts: ["all"], year: 2025 },
  { id: "n25-003", date: "2025-04-10", title: "Mahavir Jayanti", type: "national", courts: ["all"], year: 2025 },
  { id: "n25-004", date: "2025-04-18", title: "Good Friday", type: "national", courts: ["all"], year: 2025 },
  { id: "n25-005", date: "2025-08-15", title: "Independence Day", type: "national", courts: ["all"], year: 2025 },
  { id: "n25-006", date: "2025-10-02", title: "Gandhi Jayanti", type: "national", courts: ["all"], year: 2025 },
  { id: "n25-007", date: "2025-10-20", title: "Diwali", type: "national", courts: ["all"], year: 2025 },
  { id: "n25-008", date: "2025-12-25", title: "Christmas Day", type: "national", courts: ["all"], year: 2025 },

  // ── SUPREME COURT OF INDIA — specific holidays ────────────────────────────
  { id: "sc-h001", date: "2026-01-06", title: "Guru Gobind Singh Jayanti (SC closed)", type: "gazetted", courts: ["supreme_court", "punjab_hc"], year: 2026 },

  // ── DELHI HIGH COURT — specific holidays ──────────────────────────────────
  { id: "dhc-h001", date: "2026-01-13", title: "Lohri (Delhi HC)", type: "court_specific", courts: ["delhi_hc", "punjab_hc"], year: 2026, description: "Lohri festival — typically observed in Delhi/Punjab courts." },
  { id: "dhc-h002", date: "2026-11-19", title: "Chhath Puja (Delhi HC)", type: "court_specific", courts: ["delhi_hc", "allahabad_hc", "patna_hc"], year: 2026, description: "Chhath Puja — major festival in Bihar/UP, widely observed in Delhi. Courts closed on this day." },
  { id: "dhc-h003", date: "2026-11-20", title: "Chhath Puja 2nd day (Delhi HC)", type: "court_specific", courts: ["delhi_hc", "patna_hc"], year: 2026 },
  { id: "dhc-h004", date: "2026-10-22", title: "Bhai Dooj (Delhi HC)", type: "court_specific", courts: ["delhi_hc", "allahabad_hc"], year: 2026 },

  // ── BOMBAY HIGH COURT — specific holidays ─────────────────────────────────
  { id: "bhc-h001", date: "2026-05-01", title: "Maharashtra Day / Labour Day (Bombay HC)", type: "gazetted", courts: ["bombay_hc"], year: 2026, description: "Maharashtra State Foundation Day — 1 May 1960. Bombay HC closed." },
  { id: "bhc-h002", date: "2026-09-02", title: "Ganesh Chaturthi (Bombay HC)", type: "court_specific", courts: ["bombay_hc"], year: 2026, description: "Major festival in Maharashtra. Bombay HC observes Ganesh Chaturthi as a holiday." },
  { id: "bhc-h003", date: "2026-04-19", title: "Gudi Padwa (Bombay HC)", type: "court_specific", courts: ["bombay_hc", "hyderabad_hc"], year: 2026, description: "Marathi/Telugu New Year. Bombay HC and Telangana HC closed." },

  // ── MADRAS HIGH COURT — specific holidays ─────────────────────────────────
  { id: "mhc-h001", date: "2026-01-15", title: "Thiruvalluvar Day / Pongal 2nd day (Madras HC)", type: "court_specific", courts: ["madras_hc"], year: 2026 },
  { id: "mhc-h002", date: "2026-01-16", title: "Uzhavar Thirunal / Pongal 3rd day (Madras HC)", type: "court_specific", courts: ["madras_hc"], year: 2026 },
  { id: "mhc-h003", date: "2026-04-15", title: "Tamil New Year / Puthandu (Madras HC)", type: "court_specific", courts: ["madras_hc"], year: 2026, description: "Tamil New Year — falls the day after Ambedkar Jayanti. Madras HC closed." },
  { id: "mhc-h004", date: "2026-07-27", title: "Aadi Perukku (Madras HC)", type: "court_specific", courts: ["madras_hc"], year: 2026, description: "18th of the Tamil month Aadi — a Tamil festival. Madras HC observes it." },
  { id: "mhc-h005", date: "2026-12-04", title: "Karthigai Deepam (Madras HC)", type: "court_specific", courts: ["madras_hc"], year: 2026 },
  { id: "mhc-h006", date: "2026-05-01", title: "Tamil Nadu Labour Day (Madras HC)", type: "gazetted", courts: ["madras_hc"], year: 2026 },

  // ── CALCUTTA HIGH COURT — specific holidays ───────────────────────────────
  { id: "chc-h001", date: "2026-01-23", title: "Netaji Subhas Chandra Bose Jayanti (Calcutta HC)", type: "court_specific", courts: ["calcutta_hc"], year: 2026, description: "Observed as public holiday in West Bengal." },
  { id: "chc-h002", date: "2026-05-09", title: "Rabindra Jayanti (Calcutta HC)", type: "court_specific", courts: ["calcutta_hc"], year: 2026, description: "Birthday of Rabindranath Tagore (25 Baisakh). Calcutta HC closed." },
  { id: "chc-h003", date: "2026-10-05", title: "Maha Saptami / Durga Puja (Calcutta HC)", type: "court_specific", courts: ["calcutta_hc"], year: 2026 },
  { id: "chc-h004", date: "2026-10-06", title: "Maha Ashtami / Durga Puja (Calcutta HC)", type: "court_specific", courts: ["calcutta_hc"], year: 2026 },
  { id: "chc-h005", date: "2026-10-07", title: "Maha Navami / Durga Puja (Calcutta HC)", type: "court_specific", courts: ["calcutta_hc"], year: 2026 },
  { id: "chc-h006", date: "2026-10-19", title: "Kali Puja (Calcutta HC)", type: "court_specific", courts: ["calcutta_hc"], year: 2026 },
  { id: "chc-h007", date: "2026-10-20", title: "Bhai Phota (Calcutta HC)", type: "court_specific", courts: ["calcutta_hc"], year: 2026 },
  { id: "chc-h008", date: "2026-11-05", title: "Jagadhatri Puja (Calcutta HC)", type: "court_specific", courts: ["calcutta_hc"], year: 2026 },

  // ── KARNATAKA HIGH COURT — specific holidays ──────────────────────────────
  { id: "karhc-h001", date: "2026-03-30", title: "Ugadi / Kannada New Year (Karnataka HC)", type: "court_specific", courts: ["karnataka_hc", "hyderabad_hc"], year: 2026, description: "Telugu/Kannada New Year (Yugadi). Karnataka HC and Telangana HC closed." },
  { id: "karhc-h002", date: "2026-08-07", title: "Varamahalakshmi Vrata (Karnataka HC)", type: "court_specific", courts: ["karnataka_hc"], year: 2026 },
  { id: "karhc-h003", date: "2026-11-01", title: "Kannada Rajyotsava (Karnataka HC)", type: "court_specific", courts: ["karnataka_hc"], year: 2026, description: "Karnataka State Formation Day — 1 November 1956. Karnataka HC closed." },
  { id: "karhc-h004", date: "2026-10-02", title: "Dasara begins (Karnataka HC)", type: "court_specific", courts: ["karnataka_hc"], year: 2026, description: "Vijayadashami — Mysuru Dasara, especially celebrated in Karnataka." },
  { id: "karhc-h005", date: "2026-10-03", title: "Dasara (Karnataka HC)", type: "court_specific", courts: ["karnataka_hc"], year: 2026 },
  { id: "karhc-h006", date: "2026-10-04", title: "Dasara (Karnataka HC)", type: "court_specific", courts: ["karnataka_hc"], year: 2026 },
  { id: "karhc-h007", date: "2026-10-05", title: "Dasara (Karnataka HC)", type: "court_specific", courts: ["karnataka_hc"], year: 2026 },

  // ── ALLAHABAD HIGH COURT — specific holidays ──────────────────────────────
  { id: "ahc-h001", date: "2026-01-14", title: "Makar Sankranti / Khichdi (Allahabad HC)", type: "court_specific", courts: ["allahabad_hc"], year: 2026, description: "Extra holiday for Allahabad HC — Sankranti/Khichdi mela significance." },
  { id: "ahc-h002", date: "2026-03-04", title: "Holi-Dhuredi (UP HC / Allahabad)", type: "court_specific", courts: ["allahabad_hc", "mp_hc"], year: 2026, description: "Confirmed: MPHC/Allahabad HC closed for Holi-Dhuredi on 4 March 2026." },
  { id: "ahc-h003", date: "2026-10-22", title: "Bhai Dooj (Allahabad HC)", type: "court_specific", courts: ["allahabad_hc"], year: 2026 },
  { id: "ahc-h004", date: "2026-11-10", title: "Kartik Purnima (Allahabad HC)", type: "court_specific", courts: ["allahabad_hc"], year: 2026, description: "Dev Diwali — Kartik Purnima mela in Prayagraj." },

  // ── GUJARAT HIGH COURT — specific holidays ────────────────────────────────
  { id: "ghc-h001", date: "2026-01-15", title: "Uttarayan 2nd day (Gujarat HC)", type: "court_specific", courts: ["gujarat_hc"], year: 2026, description: "Kite festival continues — Gujarat HC may close for second day." },
  { id: "ghc-h002", date: "2026-05-01", title: "Gujarat National Labour Day (Gujarat HC)", type: "gazetted", courts: ["gujarat_hc"], year: 2026 },
  { id: "ghc-h003", date: "2026-10-18", title: "Dhantera (Gujarat HC)", type: "court_specific", courts: ["gujarat_hc"], year: 2026, description: "Dhanteras — major shopping festival before Diwali in Gujarat." },
  { id: "ghc-h004", date: "2026-10-24", title: "Bestu Varas / Gujarati New Year (Gujarat HC)", type: "court_specific", courts: ["gujarat_hc"], year: 2026, description: "Gujarati New Year — day after Diwali. Gujarat HC closed." },
  { id: "ghc-h005", date: "2026-10-25", title: "Bhai Beej (Gujarat HC)", type: "court_specific", courts: ["gujarat_hc"], year: 2026 },

  // ── KERALA HIGH COURT — specific holidays ─────────────────────────────────
  { id: "khc-h001", date: "2026-04-15", title: "Vishu (Kerala HC)", type: "court_specific", courts: ["kerala_hc"], year: 2026, description: "Malayalam New Year — falls a day after Ambedkar Jayanti. Kerala HC closed." },
  { id: "khc-h002", date: "2026-12-26", title: "Christmas 2nd day (Kerala HC)", type: "court_specific", courts: ["kerala_hc"], year: 2026, description: "St. Stephen's Day — Kerala HC observes December 26 as holiday." },

  // ── PUNJAB & HARYANA HIGH COURT — specific holidays ───────────────────────
  { id: "phhc-h001", date: "2026-01-13", title: "Lohri (Punjab & Haryana HC)", type: "court_specific", courts: ["punjab_hc"], year: 2026, description: "Winter harvest festival in Punjab/Haryana." },
  { id: "phhc-h002", date: "2026-04-13", title: "Baisakhi (Punjab & Haryana HC)", type: "court_specific", courts: ["punjab_hc"], year: 2026, description: "Harvest festival and Sikh New Year. Major holiday for Punjab HC." },

  // ── RAJASTHAN HIGH COURT — specific holidays ──────────────────────────────
  { id: "rjhc-h001", date: "2026-03-27", title: "Gangaur (Rajasthan HC)", type: "court_specific", courts: ["rajasthan_hc"], year: 2026, description: "Goddess Gauri worship — major Rajasthani festival. Rajasthan HC closed." },
  { id: "rjhc-h002", date: "2026-07-27", title: "Teej (Rajasthan HC)", type: "court_specific", courts: ["rajasthan_hc"], year: 2026, description: "Hariyali Teej — Rajasthani festival for married women." },

  // ── MADHYA PRADESH HIGH COURT — specific holidays ─────────────────────────
  { id: "mphc-h001", date: "2026-03-04", title: "Holi-Dhuredi (MP HC)", type: "court_specific", courts: ["mp_hc"], year: 2026, description: "Officially confirmed by MPHC notification dated 12-02-2026. HC closed 4 March 2026." },
  { id: "mphc-h002", date: "2026-04-02", title: "Mahaveer Jayanti – HC holiday (MP HC)", type: "court_specific", courts: ["mp_hc"], year: 2026 },
  { id: "mphc-h003", date: "2026-11-01", title: "Madhya Pradesh Rajyotsava (MP HC)", type: "court_specific", courts: ["mp_hc"], year: 2026, description: "MP State Formation Day." },

  // ── PATNA HIGH COURT — specific holidays ──────────────────────────────────
  { id: "pthc-h001", date: "2026-10-30", title: "Chhath Puja — Nahay Khay (Patna HC)", type: "court_specific", courts: ["patna_hc"], year: 2026, description: "Chhath Puja Day 1 — Patna HC closed for all 4 days of Chhath." },
  { id: "pthc-h002", date: "2026-10-31", title: "Chhath Puja — Kharna (Patna HC)", type: "court_specific", courts: ["patna_hc"], year: 2026 },
  { id: "pthc-h003", date: "2026-11-01", title: "Chhath Puja — Sandhya Arghya (Patna HC)", type: "court_specific", courts: ["patna_hc"], year: 2026, description: "Evening offering to Sun god — Patna HC closed." },
  { id: "pthc-h004", date: "2026-11-02", title: "Chhath Puja — Usha Arghya (Patna HC)", type: "court_specific", courts: ["patna_hc"], year: 2026, description: "Morning offering — final day of Chhath." },
  { id: "pthc-h005", date: "2026-04-06", title: "Sarhul (Patna HC — Jharkhand/Bihar)", type: "court_specific", courts: ["patna_hc"], year: 2026, description: "Sarhul — tribal forest worship festival in Bihar/Jharkhand." },

  // ── TELANGANA (HYDERABAD) HIGH COURT — specific holidays ──────────────────
  { id: "tshc-h001", date: "2026-03-30", title: "Ugadi / Telugu New Year (Telangana HC)", type: "court_specific", courts: ["hyderabad_hc"], year: 2026, description: "Telugu New Year — major holiday for Telangana HC." },
  { id: "tshc-h002", date: "2026-08-15", title: "Bonalu (Hyderabad HC)", type: "court_specific", courts: ["hyderabad_hc"], year: 2026, description: "Bonalu — Telangana state festival (date varies, generally July/August)." },
  { id: "tshc-h003", date: "2026-06-02", title: "Telangana Formation Day (Hyderabad HC)", type: "court_specific", courts: ["hyderabad_hc"], year: 2026, description: "Telangana state formation, 2 June 2014. HC closed." },
  { id: "tshc-h004", date: "2026-10-07", title: "Dasara / Vijayadashami (Telangana HC)", type: "court_specific", courts: ["hyderabad_hc"], year: 2026 },
];

// ── COURT VACATION RANGES 2026 ─────────────────────────────────────────────────
// These are expanded to individual days by the calendar API.
export const courtVacations: CourtVacation[] = [
  // Supreme Court of India
  { id: "vac-sc-sum", name: "Supreme Court Summer Vacation", startDate: "2026-05-09", endDate: "2026-06-07", courts: ["supreme_court"], year: 2026, description: "SC Summer Vacation 2026 (9 May – 7 June). Vacation Bench operates for urgent matters. Source: sci.gov.in" },
  { id: "vac-sc-dus", name: "Supreme Court Dussehra Vacation", startDate: "2026-10-03", endDate: "2026-10-16", courts: ["supreme_court"], year: 2026, description: "Supreme Court Dussehra/Puja Vacation (approx. 2 weeks). Vacation Bench available for urgent matters." },
  { id: "vac-sc-win", name: "Supreme Court Winter Vacation", startDate: "2026-12-19", endDate: "2026-12-31", courts: ["supreme_court"], year: 2026, description: "SC Winter Vacation 2026 (19 Dec – 3 Jan 2027). Source: sci.gov.in" },

  // Delhi High Court
  { id: "vac-dhc-sum", name: "Delhi HC Summer Vacation", startDate: "2026-05-16", endDate: "2026-06-14", courts: ["delhi_hc"], year: 2026, description: "Delhi HC Summer Vacation (16 May – 14 June 2026). Vacation Bench available. Source: delhihighcourt.nic.in" },
  { id: "vac-dhc-dus", name: "Delhi HC Dussehra Vacation", startDate: "2026-10-03", endDate: "2026-10-17", courts: ["delhi_hc"], year: 2026, description: "Delhi HC Dussehra Vacation (approx. 3–17 October 2026)." },
  { id: "vac-dhc-win", name: "Delhi HC Winter Vacation", startDate: "2026-12-25", endDate: "2026-12-31", courts: ["delhi_hc"], year: 2026, description: "Delhi HC Winter Vacation (25 Dec – 2 Jan 2027)." },

  // Bombay High Court
  { id: "vac-bhc-sum", name: "Bombay HC Summer Vacation", startDate: "2026-05-02", endDate: "2026-05-31", courts: ["bombay_hc"], year: 2026, description: "Bombay HC Summer Vacation (2–31 May 2026). Vacation Bench operates. Source: bombayhighcourt.nic.in" },
  { id: "vac-bhc-gan", name: "Bombay HC Ganesh Chaturthi Vacation", startDate: "2026-08-28", endDate: "2026-09-07", courts: ["bombay_hc"], year: 2026, description: "Bombay HC Ganesh Chaturthi Vacation (approx. 28 Aug – 7 Sep 2026)." },
  { id: "vac-bhc-win", name: "Bombay HC Winter Vacation", startDate: "2026-12-25", endDate: "2026-12-31", courts: ["bombay_hc"], year: 2026, description: "Bombay HC Winter Vacation." },

  // Madras High Court
  { id: "vac-mhc-sum", name: "Madras HC Summer Vacation", startDate: "2026-05-16", endDate: "2026-06-14", courts: ["madras_hc"], year: 2026, description: "Madras HC Summer Vacation (16 May – 14 June 2026). Source: hcmadras.tn.nic.in" },
  { id: "vac-mhc-pk",  name: "Madras HC Pongal Vacation", startDate: "2026-01-14", endDate: "2026-01-16", courts: ["madras_hc"], year: 2026, description: "Madras HC Pongal Vacation (14–16 January 2026)." },
  { id: "vac-mhc-win", name: "Madras HC Winter Vacation", startDate: "2026-12-24", endDate: "2026-12-31", courts: ["madras_hc"], year: 2026 },

  // Calcutta High Court
  { id: "vac-chc-dp",  name: "Calcutta HC Durga Puja Vacation", startDate: "2026-10-03", endDate: "2026-10-14", courts: ["calcutta_hc"], year: 2026, description: "Calcutta HC Durga Puja Vacation (approx. 3–14 October 2026). Source: calcuttahighcourt.gov.in" },
  { id: "vac-chc-win", name: "Calcutta HC Winter Vacation", startDate: "2026-12-24", endDate: "2026-12-31", courts: ["calcutta_hc"], year: 2026 },

  // Allahabad High Court
  { id: "vac-ahc-sum", name: "Allahabad HC Summer Vacation", startDate: "2026-05-16", endDate: "2026-06-30", courts: ["allahabad_hc"], year: 2026, description: "Allahabad HC Summer Vacation (16 May – 30 June 2026). One of the longest HC summer vacations. Source: allahabadhighcourt.in" },
  { id: "vac-ahc-dus", name: "Allahabad HC Dussehra Vacation", startDate: "2026-10-03", endDate: "2026-10-17", courts: ["allahabad_hc"], year: 2026 },
  { id: "vac-ahc-win", name: "Allahabad HC Winter Vacation", startDate: "2026-12-24", endDate: "2026-12-31", courts: ["allahabad_hc"], year: 2026 },

  // Karnataka High Court
  { id: "vac-karhc-sum", name: "Karnataka HC Summer Vacation", startDate: "2026-05-16", endDate: "2026-06-14", courts: ["karnataka_hc"], year: 2026, description: "Karnataka HC Summer Vacation. Source: karnatakajudiciary.gov.in" },
  { id: "vac-karhc-das", name: "Karnataka HC Dasara Vacation", startDate: "2026-10-03", endDate: "2026-10-11", courts: ["karnataka_hc"], year: 2026, description: "Karnataka HC Dasara/Navaratri Vacation (Mysuru Dasara)." },
  { id: "vac-karhc-win", name: "Karnataka HC Winter Vacation", startDate: "2026-12-25", endDate: "2026-12-31", courts: ["karnataka_hc"], year: 2026 },

  // Kerala High Court
  { id: "vac-khc-onam", name: "Kerala HC Onam Vacation", startDate: "2026-08-22", endDate: "2026-09-01", courts: ["kerala_hc"], year: 2026, description: "Kerala HC Onam Vacation (Atham to Thiruvonam+1, approx. 11 days). Source: hckerala.gov.in" },
  { id: "vac-khc-win",  name: "Kerala HC Christmas Vacation", startDate: "2026-12-25", endDate: "2026-12-31", courts: ["kerala_hc"], year: 2026 },

  // Gujarat High Court
  { id: "vac-ghc-sum", name: "Gujarat HC Summer Vacation", startDate: "2026-05-16", endDate: "2026-06-14", courts: ["gujarat_hc"], year: 2026, description: "Gujarat HC Summer Vacation. Source: gujarathighcourt.nic.in" },
  { id: "vac-ghc-win", name: "Gujarat HC Winter Vacation", startDate: "2026-12-25", endDate: "2026-12-31", courts: ["gujarat_hc"], year: 2026 },

  // Punjab & Haryana High Court
  { id: "vac-phhc-sum", name: "Punjab & Haryana HC Summer Vacation", startDate: "2026-05-16", endDate: "2026-06-14", courts: ["punjab_hc"], year: 2026, description: "Punjab & Haryana HC Summer Vacation. Source: punjabandharyanacourtis.gov.in" },
  { id: "vac-phhc-win", name: "Punjab & Haryana HC Winter Vacation", startDate: "2026-12-25", endDate: "2026-12-31", courts: ["punjab_hc"], year: 2026 },

  // Rajasthan High Court
  { id: "vac-rjhc-sum", name: "Rajasthan HC Summer Vacation", startDate: "2026-05-16", endDate: "2026-06-14", courts: ["rajasthan_hc"], year: 2026, description: "Rajasthan HC Summer Vacation. Source: hcraj.nic.in" },
  { id: "vac-rjhc-win", name: "Rajasthan HC Winter Vacation", startDate: "2026-12-25", endDate: "2026-12-31", courts: ["rajasthan_hc"], year: 2026 },

  // Madhya Pradesh High Court
  { id: "vac-mphc-sum", name: "MP HC Summer Vacation", startDate: "2026-05-16", endDate: "2026-06-14", courts: ["mp_hc"], year: 2026, description: "MP HC Summer Vacation. Source: mphc.gov.in" },
  { id: "vac-mphc-win", name: "MP HC Winter Vacation", startDate: "2026-12-25", endDate: "2026-12-31", courts: ["mp_hc"], year: 2026 },

  // Patna High Court
  { id: "vac-pthc-sum", name: "Patna HC Summer Vacation", startDate: "2026-05-16", endDate: "2026-06-14", courts: ["patna_hc"], year: 2026, description: "Patna HC Summer Vacation. Source: patnahighcourt.gov.in" },
  { id: "vac-pthc-win", name: "Patna HC Winter Vacation", startDate: "2026-12-25", endDate: "2026-12-31", courts: ["patna_hc"], year: 2026 },

  // Telangana High Court (Hyderabad)
  { id: "vac-tshc-sum", name: "Telangana HC Summer Vacation", startDate: "2026-05-16", endDate: "2026-06-14", courts: ["hyderabad_hc"], year: 2026, description: "Telangana HC Summer Vacation. Source: tshc.gov.in" },
  { id: "vac-tshc-das", name: "Telangana HC Dasara Vacation", startDate: "2026-10-03", endDate: "2026-10-11", courts: ["hyderabad_hc"], year: 2026 },
  { id: "vac-tshc-win", name: "Telangana HC Winter Vacation", startDate: "2026-12-25", endDate: "2026-12-31", courts: ["hyderabad_hc"], year: 2026 },
];

