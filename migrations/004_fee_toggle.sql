-- Migration: เปิด/ปิดการรวมค่าบริการประจำเดือนของแต่ละเคสในแต่ละเดือนได้ (ค่าเริ่มต้นคือรวม)
-- ใช้กับฐานข้อมูลที่ deploy ไปแล้วเท่านั้น (ฐานข้อมูลใหม่จะได้ตารางนี้จาก schema.sql อยู่แล้ว)
-- รันครั้งเดียว: wrangler d1 execute care-billing-db --remote --file=./migrations/004_fee_toggle.sql

CREATE TABLE IF NOT EXISTS fee_toggles (
  case_id  TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  ym       TEXT NOT NULL,
  included INTEGER NOT NULL DEFAULT 1,
  PRIMARY KEY (case_id, ym)
);
