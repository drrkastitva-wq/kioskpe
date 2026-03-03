import { Router, Request, Response } from "express";
import { cases, addHelpRequest } from "../data";

const router = Router();

// ─── GET /api/track/:caseId ──────────────────────────────────────────────────
// Public endpoint — clients enter a case ID to track their case.
router.get("/:caseId", (req: Request, res: Response) => {
  const id = (req.params["caseId"] as string ?? "").toUpperCase();
  if (!id) {
    return res.status(400).json({ message: "Case ID is required" });
  }

  // Look up in live cases store (case number matches)
  const found = cases.find(
    (c) => c.caseNumber.toUpperCase() === id || c.id.toUpperCase() === id
  );

  if (!found) {
    return res.status(404).json({
      message: `No case found with ID "${id}". Please verify the Case ID with your advocate.`,
    });
  }

  // Return public-facing view (no sensitive advocate IDs etc.)
  return res.json({
    id: found.caseNumber,
    title: found.title,
    caseType: found.caseType,
    status: statusLabel(found.status),
    court: found.courtName,
    advocate: "Your assigned advocate",
    clientName: found.clientName,
    filedDate: found.filedDate,
    nextHearing: found.nextHearingDate ?? "TBD",
    timeline: found.timeline,
    notes: found.notes ?? "",
  });
});

function statusLabel(s: string): string {
  const map: Record<string, string> = {
    open: "Filed / Open",
    in_progress: "Hearing Scheduled",
    adjourned: "Adjourned",
    decided: "Decided",
    closed: "Closed",
  };
  return map[s] ?? s;
}

// ─── POST /api/client/help-requests ─────────────────────────────────────────
// Called via /api/client/help-requests (client prefix mounted in index.ts)
router.post("/help-requests", (req: Request, res: Response) => {
  const { fullName, mobile, description, category, preferredCourt, contactPreference } =
    req.body ?? {};

  if (!fullName || !mobile || !description) {
    return res.status(400).json({ message: "fullName, mobile and description are required" });
  }

  const newReq = addHelpRequest({
    fullName,
    mobile,
    description,
    category: category ?? "Other",
    preferredCourt: preferredCourt ?? "Any",
    contactPreference: contactPreference ?? "Any",
  });

  return res.status(201).json({
    message: "Help request submitted successfully",
    refNumber: newReq.refNumber,
    id: newReq.id,
  });
});

export { router as caseTrackerRouter };

