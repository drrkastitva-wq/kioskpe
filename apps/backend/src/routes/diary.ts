import { Router } from "express";
import { pool } from "../db/postgres";
import { requireAdvocate, AuthenticatedRequest } from "../middleware/auth";

export const diaryRouter = Router();

// GET /api/diary
diaryRouter.get("/", requireAdvocate, async (req: AuthenticatedRequest, res) => {
  const { rows } = await pool.query(
    "SELECT * FROM diary_entries WHERE advocate_id = $1 ORDER BY date DESC", [req.userId]
  );
  return res.json(rows.map((r) => ({
    id: r.id, date: r.date, title: r.title, notes: r.notes,
    category: r.category, linkedCaseId: r.linked_case_id, createdAt: r.created_at,
  })));
});

// POST /api/diary
diaryRouter.post("/", requireAdvocate, async (req: AuthenticatedRequest, res) => {
  const { date, title, notes, category, linkedCaseId } = req.body ?? {};
  if (!date || !title || !notes)
    return res.status(400).json({ message: "date, title and notes are required" });
  const { rows } = await pool.query(
    "INSERT INTO diary_entries (advocate_id, date, title, notes, category, linked_case_id) VALUES ($1,$2,$3,$4,$5,$6) RETURNING *",
    [req.userId, date, title, notes, category ?? "other", linkedCaseId ?? null]
  );
  const r = rows[0];
  return res.status(201).json({
    id: r.id, date: r.date, title: r.title, notes: r.notes,
    category: r.category, linkedCaseId: r.linked_case_id, createdAt: r.created_at,
  });
});

// DELETE /api/diary/:id
diaryRouter.delete("/:id", requireAdvocate, async (req: AuthenticatedRequest, res) => {
  const { rowCount } = await pool.query(
    "DELETE FROM diary_entries WHERE id = $1 AND advocate_id = $2", [req.params.id, req.userId]
  );
  if (!rowCount) return res.status(404).json({ message: "Entry not found" });
  return res.status(204).send();
});

