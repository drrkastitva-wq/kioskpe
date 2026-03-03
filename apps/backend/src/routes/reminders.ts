import { Router } from "express";
import { pool } from "../db/postgres";
import { requireAdvocate, AuthenticatedRequest } from "../middleware/auth";

export const remindersRouter = Router();

// GET /api/reminders
remindersRouter.get("/", requireAdvocate, async (req: AuthenticatedRequest, res) => {
  const { rows } = await pool.query(
    "SELECT * FROM reminders WHERE advocate_id = $1 ORDER BY due_date ASC", [req.userId]
  );
  return res.json(rows.map((r) => ({
    id: r.id, caseId: r.case_id, title: r.title, dueDate: r.due_date,
    priority: r.priority, isCompleted: r.is_completed, createdAt: r.created_at,
  })));
});

// POST /api/reminders
remindersRouter.post("/", requireAdvocate, async (req: AuthenticatedRequest, res) => {
  const { title, dueDate, priority, caseId } = req.body ?? {};
  if (!title || !dueDate)
    return res.status(400).json({ message: "title and dueDate are required" });
  const { rows } = await pool.query(
    "INSERT INTO reminders (advocate_id, case_id, title, due_date, priority) VALUES ($1,$2,$3,$4,$5) RETURNING *",
    [req.userId, caseId ?? null, title, dueDate, priority ?? "medium"]
  );
  const r = rows[0];
  return res.status(201).json({
    id: r.id, caseId: r.case_id, title: r.title, dueDate: r.due_date,
    priority: r.priority, isCompleted: r.is_completed, createdAt: r.created_at,
  });
});

// PATCH /api/reminders/:id
remindersRouter.patch("/:id", requireAdvocate, async (req: AuthenticatedRequest, res) => {
  const b = req.body as Record<string, unknown>;
  const { rows } = await pool.query(
    `UPDATE reminders
     SET title = COALESCE($1, title), due_date = COALESCE($2, due_date),
         priority = COALESCE($3, priority), is_completed = COALESCE($4, is_completed),
         case_id = COALESCE($5, case_id)
     WHERE id = $6 AND advocate_id = $7 RETURNING *`,
    [b.title ?? null, b.dueDate ?? null, b.priority ?? null, b.isCompleted ?? null, b.caseId ?? null,
     req.params.id, req.userId]
  );
  if (!rows[0]) return res.status(404).json({ message: "Reminder not found" });
  const r = rows[0];
  return res.json({
    id: r.id, caseId: r.case_id, title: r.title, dueDate: r.due_date,
    priority: r.priority, isCompleted: r.is_completed, createdAt: r.created_at,
  });
});

// DELETE /api/reminders/:id
remindersRouter.delete("/:id", requireAdvocate, async (req: AuthenticatedRequest, res) => {
  const { rowCount } = await pool.query(
    "DELETE FROM reminders WHERE id = $1 AND advocate_id = $2", [req.params.id, req.userId]
  );
  if (!rowCount) return res.status(404).json({ message: "Reminder not found" });
  return res.status(204).send();
});

