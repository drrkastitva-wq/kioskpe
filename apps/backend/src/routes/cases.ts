import { Router } from "express";
import { pool } from "../db/postgres";
import { requireAdvocate, AuthenticatedRequest } from "../middleware/auth";

function rowToCase(r: Record<string, unknown>) {
  return {
    id: r.id, caseNumber: r.case_number, title: r.title, caseType: r.case_type,
    clientName: r.client_name, clientPhone: r.client_phone, opposingParty: r.opposing_party,
    courtName: r.court_name, courtType: r.court_type, judgeOrBench: r.judge_or_bench,
    filedDate: r.filed_date, nextHearingDate: r.next_hearing_date, status: r.status,
    advocateId: r.advocate_id, notes: r.notes, timeline: r.timeline ?? [],
    createdAt: r.created_at, updatedAt: r.updated_at,
  };
}

export const casesRouter = Router();

// GET /api/cases
casesRouter.get("/", requireAdvocate, async (req: AuthenticatedRequest, res) => {
  const { rows } = await pool.query(
    "SELECT * FROM cases WHERE advocate_id = $1 ORDER BY updated_at DESC",
    [req.userId]
  );
  return res.json(rows.map(rowToCase));
});

// GET /api/cases/:id
casesRouter.get("/:id", requireAdvocate, async (req: AuthenticatedRequest, res) => {
  const { rows } = await pool.query(
    "SELECT * FROM cases WHERE (id = $1 OR case_number = $1) AND advocate_id = $2",
    [req.params.id, req.userId]
  );
  if (!rows[0]) return res.status(404).json({ message: "Case not found" });
  return res.json(rowToCase(rows[0]));
});

// POST /api/cases
casesRouter.post("/", requireAdvocate, async (req: AuthenticatedRequest, res) => {
  const {
    title, caseNumber, caseType, clientName, clientPhone, opposingParty,
    courtName, courtType, judgeOrBench, nextHearingDate, filedDate, status, notes, timeline,
  } = req.body ?? {};
  if (!title || !clientName || !courtName)
    return res.status(400).json({ message: "title, clientName and courtName are required" });

  const autoNumber = caseNumber ||
    `LL-${new Date().getFullYear()}-${Math.random().toString(36).slice(2, 10).toUpperCase()}`;

  const { rows } = await pool.query(
    `INSERT INTO cases (case_number, title, case_type, client_name, client_phone,
      opposing_party, court_name, court_type, judge_or_bench, next_hearing_date,
      filed_date, status, advocate_id, notes, timeline)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15) RETURNING *`,
    [
      autoNumber, title, caseType ?? "Civil", clientName, clientPhone ?? null,
      opposingParty ?? null, courtName, courtType ?? "High Court", judgeOrBench ?? null,
      nextHearingDate ?? null, filedDate ?? new Date().toISOString().split("T")[0],
      status ?? "open", req.userId, notes ?? null, JSON.stringify(timeline ?? []),
    ]
  );
  return res.status(201).json(rowToCase(rows[0]));
});

// PATCH /api/cases/:id
casesRouter.patch("/:id", requireAdvocate, async (req: AuthenticatedRequest, res) => {
  const b = req.body as Record<string, unknown>;
  const { rows } = await pool.query(
    `UPDATE cases SET
      title = COALESCE($1, title), case_type = COALESCE($2, case_type),
      client_name = COALESCE($3, client_name), client_phone = COALESCE($4, client_phone),
      opposing_party = COALESCE($5, opposing_party), court_name = COALESCE($6, court_name),
      court_type = COALESCE($7, court_type), judge_or_bench = COALESCE($8, judge_or_bench),
      next_hearing_date = COALESCE($9, next_hearing_date), filed_date = COALESCE($10, filed_date),
      status = COALESCE($11, status), notes = COALESCE($12, notes), updated_at = NOW()
     WHERE id = $13 AND advocate_id = $14 RETURNING *`,
    [
      b.title ?? null, b.caseType ?? null, b.clientName ?? null, b.clientPhone ?? null,
      b.opposingParty ?? null, b.courtName ?? null, b.courtType ?? null, b.judgeOrBench ?? null,
      b.nextHearingDate ?? null, b.filedDate ?? null, b.status ?? null, b.notes ?? null,
      req.params.id, req.userId,
    ]
  );
  if (!rows[0]) return res.status(404).json({ message: "Case not found" });
  return res.json(rowToCase(rows[0]));
});

// PATCH /api/cases/:id/timeline
casesRouter.patch("/:id/timeline", requireAdvocate, async (req: AuthenticatedRequest, res) => {
  const { date, event, status } = req.body ?? {};
  if (!date || !event) return res.status(400).json({ message: "date and event are required" });
  const { rows } = await pool.query(
    `UPDATE cases
     SET timeline = timeline || $1::jsonb, updated_at = NOW()
     WHERE id = $2 AND advocate_id = $3 RETURNING *`,
    [
      JSON.stringify([{ date, event, status: status ?? "upcoming", addedBy: req.userId }]),
      req.params.id, req.userId,
    ]
  );
  if (!rows[0]) return res.status(404).json({ message: "Case not found" });
  return res.json(rowToCase(rows[0]));
});

// DELETE /api/cases/:id
casesRouter.delete("/:id", requireAdvocate, async (req: AuthenticatedRequest, res) => {
  const { rowCount } = await pool.query(
    "DELETE FROM cases WHERE id = $1 AND advocate_id = $2", [req.params.id, req.userId]
  );
  if (!rowCount) return res.status(404).json({ message: "Case not found" });
  return res.status(204).send();
});



