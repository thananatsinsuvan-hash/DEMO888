-- Migration: เลขที่เอกสารรันอัตโนมัติแบบเป็นระบบ (แยกตามสาขา, แยกชุด invoice/receipt, รีเซ็ตทุกปี)
-- ใช้กับฐานข้อมูลที่ deploy ไปแล้วเท่านั้น
-- รันครั้งเดียว: wrangler d1 execute care-billing-db --remote --file=./migrations/007_doc_numbering.sql

ALTER TABLE branches ADD COLUMN code TEXT;

CREATE TABLE IF NOT EXISTS doc_sequences (
  branch_id TEXT NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  doc_type  TEXT NOT NULL,
  year      INTEGER NOT NULL,
  last_seq  INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (branch_id, doc_type, year)
);
