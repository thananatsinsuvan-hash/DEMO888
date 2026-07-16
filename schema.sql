-- ระบบบันทึกค่าใช้จ่ายผู้สูงอายุ — โครงสร้างฐานข้อมูล Cloudflare D1

CREATE TABLE IF NOT EXISTS orgs (
  id    TEXT PRIMARY KEY,
  name  TEXT NOT NULL,
  logo  TEXT,
  staff TEXT,
  note  TEXT
);

CREATE TABLE IF NOT EXISTS branches (
  id      TEXT PRIMARY KEY,
  org_id  TEXT NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  name    TEXT NOT NULL,
  address TEXT,
  phone   TEXT
);

CREATE TABLE IF NOT EXISTS cases (
  id           TEXT PRIMARY KEY,
  branch_id    TEXT REFERENCES branches(id) ON DELETE SET NULL,
  name         TEXT NOT NULL,
  note         TEXT,
  monthly_fee  REAL NOT NULL DEFAULT 0,
  due_day      INTEGER NOT NULL DEFAULT 1,
  bank_name    TEXT,
  bank_acc     TEXT,
  bank_owner   TEXT,
  -- ข้อมูลประวัติเบื้องต้น
  age               INTEGER,
  health_info       TEXT,   -- โรคประจำตัว / ข้อมูลสุขภาพสำคัญ
  allergy           TEXT,   -- ยาที่แพ้
  emergency_contact TEXT,   -- ชื่อผู้ติดต่อฉุกเฉิน
  emergency_phone   TEXT,   -- เบอร์โทรผู้ติดต่อฉุกเฉิน
  admission_date    TEXT,   -- วันที่เข้ารับบริการ (YYYY-MM-DD) — ใช้คำนวณ due_day อัตโนมัติ
  photo_key         TEXT    -- key ของรูปคนไข้ใน R2 bucket
);

CREATE TABLE IF NOT EXISTS entries (
  id       TEXT PRIMARY KEY,
  case_id  TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  ym       TEXT NOT NULL,   -- รูปแบบ 'YYYY-MM'
  date     TEXT,
  desc     TEXT NOT NULL,
  amount   REAL NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS payments (
  case_id      TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  ym           TEXT NOT NULL,   -- รูปแบบ 'YYYY-MM'
  paid         INTEGER NOT NULL DEFAULT 0,
  paid_date    TEXT,
  paid_amount  REAL,
  method       TEXT,
  invoice_no   TEXT,
  receipt_no   TEXT,
  PRIMARY KEY (case_id, ym)
);

-- ผู้ใช้งานระบบ — role: 'admin' เข้าถึงทุกองค์กร/สาขาได้ทั้งหมด, 'staff' เข้าถึงได้เฉพาะสาขาที่ผูกไว้
CREATE TABLE IF NOT EXISTS users (
  id            TEXT PRIMARY KEY,
  username      TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  salt          TEXT NOT NULL,
  display_name  TEXT,
  role          TEXT NOT NULL DEFAULT 'staff',   -- 'admin' | 'staff'
  org_id        TEXT REFERENCES orgs(id) ON DELETE SET NULL,
  branch_id     TEXT REFERENCES branches(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_users_branch   ON users(branch_id);

CREATE INDEX IF NOT EXISTS idx_branches_org   ON branches(org_id);
CREATE INDEX IF NOT EXISTS idx_cases_branch   ON cases(branch_id);
CREATE INDEX IF NOT EXISTS idx_entries_case   ON entries(case_id, ym);
CREATE INDEX IF NOT EXISTS idx_payments_case  ON payments(case_id, ym);
