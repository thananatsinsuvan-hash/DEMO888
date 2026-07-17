-- Migration: นัดหมอของแต่ละเคส (แสดงในปฏิทิน + เตือนให้ลงค่าใช้จ่ายค่าบริการพาไปพบแพทย์)
-- ใช้กับฐานข้อมูลที่ deploy ไปแล้วเท่านั้น
-- รันครั้งเดียว: wrangler d1 execute care-billing-db --remote --file=./migrations/009_appointments.sql

CREATE TABLE IF NOT EXISTS appointments (
  id      TEXT PRIMARY KEY,
  case_id TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  date    TEXT NOT NULL,
  note    TEXT,
  status  TEXT NOT NULL DEFAULT 'scheduled'
);
CREATE INDEX IF NOT EXISTS idx_appointments_case ON appointments(case_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(date);
