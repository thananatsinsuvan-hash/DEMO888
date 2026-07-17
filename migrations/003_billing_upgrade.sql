-- Migration: บัญชีธนาคารต่อสาขา, โลโก้อัปโหลดได้, ประเภทรายการค่าใช้จ่าย, ส่วนลด/สลิปโอนเงินในการชำระเงิน
-- ใช้กับฐานข้อมูลที่ deploy ไปแล้วเท่านั้น (ฐานข้อมูลใหม่จะได้ทั้งหมดนี้จาก schema.sql อยู่แล้ว)
-- รันครั้งเดียว: wrangler d1 execute care-billing-db --remote --file=./migrations/003_billing_upgrade.sql

CREATE TABLE IF NOT EXISTS bank_accounts (
  id         TEXT PRIMARY KEY,
  branch_id  TEXT NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  bank_name  TEXT NOT NULL,
  bank_acc   TEXT NOT NULL,
  bank_owner TEXT
);
CREATE INDEX IF NOT EXISTS idx_bank_accounts_branch ON bank_accounts(branch_id);

ALTER TABLE orgs ADD COLUMN logo_key TEXT;

ALTER TABLE cases ADD COLUMN bank_account_id TEXT REFERENCES bank_accounts(id) ON DELETE SET NULL;

ALTER TABLE entries ADD COLUMN category TEXT;

ALTER TABLE payments ADD COLUMN discount REAL DEFAULT 0;
ALTER TABLE payments ADD COLUMN slip_key TEXT;
