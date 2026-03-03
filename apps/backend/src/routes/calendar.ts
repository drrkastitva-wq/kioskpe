import { Router, Request, Response } from "express";
import { courtHolidays } from "../data";
import { CourtScope } from "../types";

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
 * GET /api/calendar/holidays
 * Query params:
 *   year   – 4-digit year (default: current year)
 *   month  – 1-12 (optional; if omitted, returns full year)
 *   court  – court scope key (optional; if omitted, returns all)
 */
router.get("/holidays", (req: Request, res: Response) => {
  const year = parseInt((req.query.year as string) ?? String(new Date().getFullYear()), 10);
  const monthParam = req.query.month as string | undefined;
  const courtParam = ((req.query.court as string) ?? "").toLowerCase().replace(/\s+/g, "_");

  let results = courtHolidays.filter((h) => h.year === year);

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
 * Returns the list of supported courts with metadata.
 */
router.get("/courts", (_req: Request, res: Response) => {
  const courts = [
    { id: "all", label: "All Courts (National)", scope: "all" },
    { id: "supreme_court", label: "Supreme Court of India", scope: "supreme_court", city: "New Delhi" },
    { id: "delhi_hc", label: "Delhi High Court", scope: "delhi_hc", city: "New Delhi" },
    { id: "bombay_hc", label: "Bombay High Court", scope: "bombay_hc", city: "Mumbai" },
    { id: "madras_hc", label: "Madras High Court", scope: "madras_hc", city: "Chennai" },
    { id: "calcutta_hc", label: "Calcutta High Court", scope: "calcutta_hc", city: "Kolkata" },
    { id: "karnataka_hc", label: "Karnataka High Court", scope: "karnataka_hc", city: "Bengaluru" },
    { id: "allahabad_hc", label: "Allahabad High Court", scope: "allahabad_hc", city: "Prayagraj" },
    { id: "gujarat_hc", label: "Gujarat High Court", scope: "gujarat_hc", city: "Ahmedabad" },
    { id: "kerala_hc", label: "Kerala High Court", scope: "kerala_hc", city: "Kochi" },
    { id: "punjab_hc", label: "Punjab & Haryana High Court", scope: "punjab_hc", city: "Chandigarh" },
    { id: "rajasthan_hc", label: "Rajasthan High Court", scope: "rajasthan_hc", city: "Jodhpur" },
    { id: "mp_hc", label: "Madhya Pradesh High Court", scope: "mp_hc", city: "Jabalpur" },
    { id: "patna_hc", label: "Patna High Court", scope: "patna_hc", city: "Patna" },
    { id: "hyderabad_hc", label: "Telangana High Court", scope: "hyderabad_hc", city: "Hyderabad" },
  ];
  return res.json({ courts });
});

export { router as calendarRouter };
