import { Router, Request, Response } from "express";
import { courtHolidays, courtVacations } from "../data";
import { CourtHoliday, CourtScope } from "../types";

const router = Router();

// Map of URL-friendly court param → CourtScope
const courtParamMap: Record<string, CourtScope> = {
  supreme_court: "supreme_court",
  "supreme court": "supreme_court",
  delhi_hc: "delhi_hc",
  bombay_hc: "bombay_hc",
  madras_hc: "madras_hc",
  calcutta_hc: "calcutta_hc",
  karnataka_hc: "karnataka_hc",
  allahabad_hc: "allahabad_hc",
  gujarat_hc: "gujarat_hc",
  kerala_hc: "kerala_hc",
  punjab_hc: "punjab_hc",
  rajasthan_hc: "rajasthan_hc",
  mp_hc: "mp_hc",
  patna_hc: "patna_hc",
  hyderabad_hc: "hyderabad_hc",
  all: "all",
};

/**
 * Expand vacation ranges into individual CourtHoliday entries.
 * Only first and last days get distinct labels; middle days share the vacation name.
 */
function expandVacations(year: number, courtParam: string): CourtHoliday[] {
  const result: CourtHoliday[] = [];
  const filtered = courtVacations.filter((v) => {
    if (v.year !== year) return false;
    if (!courtParam || courtParam === "all") return true;
    const scope = courtParamMap[courtParam] as CourtScope | undefined;
    return scope ? v.courts.includes(scope) : false;
  });

  for (const v of filtered) {
    const start = new Date(v.startDate + "T00:00:00Z");
    const end   = new Date(v.endDate   + "T00:00:00Z");
    let cur = new Date(start);
    let i = 0;
    while (cur <= end) {
      const dateStr   = cur.toISOString().split("T")[0];
      const isFirst   = i === 0;
      const isLast    = cur.getTime() === end.getTime();
      const title     = isFirst
        ? `${v.name} begins`
        : isLast
        ? `${v.name} ends`
        : v.name;
      result.push({
        id:          `${v.id}-d${i}`,
        date:        dateStr,
        title,
        description: isFirst ? (v.description ?? "") : "",
        type:        "court_vacation",
        courts:      v.courts,
        year:        v.year,
      });
      cur.setUTCDate(cur.getUTCDate() + 1);
      i++;
    }
  }
  return result;
}

/**
 * GET /api/calendar/holidays
 * Query params:
 *   year   – 4-digit year (default: current year)
 *   month  – 1-12 (optional; if omitted, returns full year)
 *   court  – court scope key (optional; if omitted, returns all)
 *   vacations – "false" to skip vacation expansion (default: included)
 */
router.get("/holidays", (req: Request, res: Response) => {
  const year = parseInt((req.query.year as string) ?? String(new Date().getFullYear()), 10);
  const monthParam = req.query.month as string | undefined;
  const courtParam = ((req.query.court as string) ?? "").toLowerCase().replace(/\s+/g, "_");
  const includeVacations = (req.query.vacations as string) !== "false";

  let results: CourtHoliday[] = courtHolidays.filter((h) => h.year === year);

  // Merge expanded vacation entries
  if (includeVacations) {
    const vacExpanded = expandVacations(year, courtParam);
    results = [...results, ...vacExpanded];
  }

  // Filter by month if provided
  if (monthParam) {
    const month = parseInt(monthParam, 10);
    if (!isNaN(month)) {
      results = results.filter((h) => {
        const d = new Date(h.date);
        return d.getMonth() + 1 === month;
      });
    }
  }

  // Filter by court scope
  if (courtParam && courtParam !== "" && courtParam !== "all") {
    const scope = courtParamMap[courtParam] as CourtScope | undefined;
    if (scope) {
      results = results.filter(
        (h) => h.courts.includes("all") || h.courts.includes(scope)
      );
    }
  }

  // Deduplicate by id (vacation expansion may overlap with static entries)
  const seen = new Set<string>();
  results = results.filter((h) => {
    if (seen.has(h.id)) return false;
    seen.add(h.id);
    return true;
  });

  // Sort by date
  results.sort((a, b) => a.date.localeCompare(b.date));

  return res.json({
    year,
    court: courtParam || "all",
    count: results.length,
    holidays: results,
  });
});

/**
 * GET /api/calendar/courts
 * Returns the list of supported courts with metadata including website links.
 */
router.get("/courts", (_req: Request, res: Response) => {
  const courts = [
    {
      id: "all", label: "All Courts (National)", scope: "all",
      city: "", state: "India",
      website: "https://ecourts.gov.in",
      description: "Shows national holidays common to all courts.",
    },
    {
      id: "supreme_court", label: "Supreme Court of India", scope: "supreme_court",
      city: "New Delhi", state: "Delhi", established: 1950,
      website: "https://www.sci.gov.in",
      calendarUrl: "https://www.sci.gov.in/holiday-information",
      description: "Apex court of India. Summer vacation bench operates for urgent matters.",
    },
    {
      id: "delhi_hc", label: "Delhi High Court", scope: "delhi_hc",
      city: "New Delhi", state: "Delhi", established: 1966,
      website: "https://www.delhihighcourt.nic.in",
      calendarUrl: "https://www.delhihighcourt.nic.in",
      description: "High Court of Delhi, established in 1966.",
    },
    {
      id: "bombay_hc", label: "Bombay High Court", scope: "bombay_hc",
      city: "Mumbai", state: "Maharashtra", established: 1862,
      website: "https://www.bombayhighcourt.nic.in",
      calendarUrl: "https://www.bombayhighcourt.nic.in",
      description: "One of India's oldest High Courts. Benches at Aurangabad, Nagpur, Goa.",
    },
    {
      id: "madras_hc", label: "Madras High Court", scope: "madras_hc",
      city: "Chennai", state: "Tamil Nadu", established: 1862,
      website: "https://www.hcmadras.tn.nic.in",
      calendarUrl: "https://www.hcmadras.tn.nic.in",
      description: "One of the oldest HCs in India, established 1862. Bench at Madurai.",
    },
    {
      id: "calcutta_hc", label: "Calcutta High Court", scope: "calcutta_hc",
      city: "Kolkata", state: "West Bengal", established: 1862,
      website: "https://www.calcuttahighcourt.gov.in",
      calendarUrl: "https://www.calcuttahighcourt.gov.in",
      description: "Oldest High Court in India, established 1862. Bench at Port Blair.",
    },
    {
      id: "karnataka_hc", label: "Karnataka High Court", scope: "karnataka_hc",
      city: "Bengaluru", state: "Karnataka", established: 1884,
      website: "https://karnatakajudiciary.gov.in",
      calendarUrl: "https://karnatakajudiciary.gov.in",
      description: "Formerly known as Mysore High Court. Major Dasara/Navaratri vacation.",
    },
    {
      id: "allahabad_hc", label: "Allahabad High Court", scope: "allahabad_hc",
      city: "Prayagraj", state: "Uttar Pradesh", established: 1866,
      website: "https://www.allahabadhighcourt.in",
      calendarUrl: "https://www.allahabadhighcourt.in/Calendar/calendar.htm",
      description: "Largest High Court in India by number of judges. Bench at Lucknow.",
    },
    {
      id: "gujarat_hc", label: "Gujarat High Court", scope: "gujarat_hc",
      city: "Ahmedabad", state: "Gujarat", established: 1960,
      website: "https://www.gujarathighcourt.nic.in",
      calendarUrl: "https://www.gujarathighcourt.nic.in",
      description: "Established in 1960 on Gujarat's formation from Bombay State.",
    },
    {
      id: "kerala_hc", label: "Kerala High Court", scope: "kerala_hc",
      city: "Kochi", state: "Kerala", established: 1958,
      website: "https://www.hckerala.gov.in",
      calendarUrl: "https://www.hckerala.gov.in",
      description: "Established in 1958. Major Onam vacation (~10 days).",
    },
    {
      id: "punjab_hc", label: "Punjab & Haryana HC", scope: "punjab_hc",
      city: "Chandigarh", state: "Punjab & Haryana & UT Chandigarh", established: 1947,
      website: "https://www.highcourtchd.gov.in",
      calendarUrl: "https://www.highcourtchd.gov.in",
      description: "Serves Punjab, Haryana, and UT Chandigarh. Established 1947.",
    },
    {
      id: "rajasthan_hc", label: "Rajasthan High Court", scope: "rajasthan_hc",
      city: "Jodhpur", state: "Rajasthan", established: 1949,
      website: "https://www.hcraj.nic.in",
      calendarUrl: "https://www.hcraj.nic.in",
      description: "Established 1949. Principal seat Jodhpur, bench at Jaipur.",
    },
    {
      id: "mp_hc", label: "MP High Court", scope: "mp_hc",
      city: "Jabalpur", state: "Madhya Pradesh", established: 1956,
      website: "https://www.mphc.gov.in",
      calendarUrl: "https://mphc.gov.in/calendar",
      description: "Principal seat Jabalpur. Benches at Gwalior and Indore.",
    },
    {
      id: "patna_hc", label: "Patna High Court", scope: "patna_hc",
      city: "Patna", state: "Bihar", established: 1916,
      website: "https://www.patnahighcourt.gov.in",
      calendarUrl: "https://www.patnahighcourt.gov.in",
      description: "Established 1916. Chhath Puja vacation is a distinctive 4-day closure.",
    },
    {
      id: "hyderabad_hc", label: "Telangana High Court", scope: "hyderabad_hc",
      city: "Hyderabad", state: "Telangana", established: 1954,
      website: "https://tshc.gov.in",
      calendarUrl: "https://tshc.gov.in",
      description: "Telangana High Court (formerly Andhra Pradesh HC). Est. 1954.",
    },
  ];
  return res.json({ courts });
});

export { router as calendarRouter };
