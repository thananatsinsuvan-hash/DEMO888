-- Migration: บิลเรียกเก็บพิเศษระหว่างเดือน (แยกอิสระจากรอบบิลค่าบริการประจำเดือน มีสถานะชำระของตัวเอง)
-- ใช้กับฐานข้อมูลที่ deploy ไปแล้วเท่านั้น (ฐานข้อมูลใหม่จะได้ตารางเหล่านี้จาก schema.sql อยู่แล้ว)
-- รันครั้งเดียว: wrangler d1 execute care-billing-db --remote --file=./migrations/005_adhoc_bills.sql

CREATE TABLE IF NOT EXISTS adhoc_bills (
  id           TEXT PRIMARY KEY,
  case_id      TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  bill_date    TEXT NOT NULL,
  note         TEXT,
  discount     REAL DEFAULT 0,
  paid         INTEGER NOT NULL DEFAULT 0,
  paid_date    TEXT,
  paid_amount  REAL,
  method       TEXT,
  invoice_no   TEXT,
  receipt_no   TEXT,
  slip_key     TEXT
);

CREATE TABLE IF NOT EXISTS adhoc_bill_items (
  id       TEXT PRIMARY KEY,
  bill_id  TEXT NOT NULL REFERENCES adhoc_bills(id) ON DELETE CASCADE,
  desc     TEXT NOT NULL,
  amount   REAL NOT NULL DEFAULT 0,
  category TEXT
);

CREATE INDEX IF NOT EXISTS idx_adhoc_bills_case ON adhoc_bills(case_id);
CREATE INDEX IF NOT EXISTS idx_adhoc_bill_items_bill ON adhoc_bill_items(bill_id);
