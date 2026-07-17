-- ระบบบันทึกค่าใช้จ่ายผู้สูงอายุ — โครงสร้างฐานข้อมูล Cloudflare D1

CREATE TABLE IF NOT EXISTS orgs (
  id       TEXT PRIMARY KEY,
  name     TEXT NOT NULL,
  logo     TEXT,
  logo_key TEXT,   -- key ของไฟล์รูปโลโก้ใน R2 bucket (ถ้าไม่มีจะใช้ตัวย่อในช่อง logo แทน)
  staff    TEXT,
  note     TEXT
);

CREATE TABLE IF NOT EXISTS branches (
  id      TEXT PRIMARY KEY,
  org_id  TEXT NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  name    TEXT NOT NULL,
  address TEXT,
  phone   TEXT,
  code    TEXT   -- รหัสสาขาแบบสั้น ใช้ประกอบเลขที่เอกสาร (เช่น NW, BKK1) — ถ้าไม่ระบุจะใช้รหัสอัตโนมัติจาก id แทน
);

-- บัญชีธนาคารของแต่ละสาขา (สาขาหนึ่งมีได้หลายบัญชี) ให้ staff เลือกตอนเพิ่ม/แก้ไขเคส
CREATE TABLE IF NOT EXISTS bank_accounts (
  id         TEXT PRIMARY KEY,
  branch_id  TEXT NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  bank_name  TEXT NOT NULL,
  bank_acc   TEXT NOT NULL,
  bank_owner TEXT
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
  bank_account_id TEXT REFERENCES bank_accounts(id) ON DELETE SET NULL,  -- บัญชีธนาคารของสาขาที่เลือกใช้กับเคสนี้
  -- ข้อมูลประวัติเบื้องต้น
  age               INTEGER,
  health_info       TEXT,   -- โรคประจำตัว / ข้อมูลสุขภาพสำคัญ
  allergy           TEXT,   -- ยาที่แพ้
  emergency_contact TEXT,   -- ชื่อผู้ติดต่อฉุกเฉิน
  emergency_phone   TEXT,   -- เบอร์โทรผู้ติดต่อฉุกเฉิน
  admission_date    TEXT,   -- วันที่เข้ารับบริการ (YYYY-MM-DD) — ใช้คำนวณ due_day อัตโนมัติ
  photo_key         TEXT,   -- key ของรูปคนไข้ใน R2 bucket
  moved_out         INTEGER NOT NULL DEFAULT 0,   -- 1 = ย้ายออกแล้ว (เก็บไว้เป็นประวัติ ไม่นับรวมในบิล/สรุปที่ใช้งานอยู่)
  move_out_date     TEXT    -- วันที่ย้ายออก (YYYY-MM-DD)
);

CREATE TABLE IF NOT EXISTS entries (
  id       TEXT PRIMARY KEY,
  case_id  TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  ym       TEXT NOT NULL,   -- รูปแบบ 'YYYY-MM'
  date     TEXT,
  desc     TEXT NOT NULL,
  amount   REAL NOT NULL DEFAULT 0,
  category TEXT   -- ประเภทรายการ เช่น deposit, procedure, escort, medicine, medicine_service_charge, other
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
  discount     REAL DEFAULT 0,   -- ส่วนลด (บาท) แสดงในใบเสร็จ
  slip_key     TEXT,             -- key ของรูปสลิปโอนเงิน/หลักฐานรับเงินสดใน R2
  PRIMARY KEY (case_id, ym)
);

-- ผู้ใช้งานระบบ — role: 'admin' เข้าถึงทุกองค์กร/สาขาได้ทั้งหมด (และกำหนดสิทธิ์ manager ได้),
-- 'manager' เข้าถึงได้เฉพาะสาขาที่ admin อนุญาต (เลือกได้หลายสาขา ดูตาราง user_branch_access),
-- 'staff' เข้าถึงได้เฉพาะสาขาเดียวที่ผูกไว้ (org_id/branch_id ด้านล่าง)
CREATE TABLE IF NOT EXISTS users (
  id            TEXT PRIMARY KEY,
  username      TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  salt          TEXT NOT NULL,
  display_name  TEXT,
  role          TEXT NOT NULL DEFAULT 'staff',   -- 'admin' | 'manager' | 'staff'
  org_id        TEXT REFERENCES orgs(id) ON DELETE SET NULL,
  branch_id     TEXT REFERENCES branches(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_users_branch   ON users(branch_id);

-- สาขาที่ manager แต่ละคนเข้าถึงได้ (ผูกได้หลายสาขา กำหนดโดย admin เท่านั้น)
CREATE TABLE IF NOT EXISTS user_branch_access (
  user_id   TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  branch_id TEXT NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, branch_id)
);
CREATE INDEX IF NOT EXISTS idx_user_branch_access_user   ON user_branch_access(user_id);
CREATE INDEX IF NOT EXISTS idx_user_branch_access_branch ON user_branch_access(branch_id);

CREATE INDEX IF NOT EXISTS idx_branches_org   ON branches(org_id);
CREATE INDEX IF NOT EXISTS idx_cases_branch   ON cases(branch_id);
CREATE INDEX IF NOT EXISTS idx_entries_case   ON entries(case_id, ym);
CREATE INDEX IF NOT EXISTS idx_payments_case  ON payments(case_id, ym);
CREATE INDEX IF NOT EXISTS idx_bank_accounts_branch ON bank_accounts(branch_id);

-- เปิด/ปิดการรวมค่าบริการประจำเดือนของแต่ละเคสในแต่ละเดือน (ค่าเริ่มต้นคือรวม ถ้าไม่มีแถวในตารางนี้)
CREATE TABLE IF NOT EXISTS fee_toggles (
  case_id  TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  ym       TEXT NOT NULL,
  included INTEGER NOT NULL DEFAULT 1,
  PRIMARY KEY (case_id, ym)
);

-- บิลเรียกเก็บพิเศษระหว่างเดือน (เช่น ค่าเวชภัณฑ์อย่างเดียว) แยกอิสระจากรอบบิลค่าบริการประจำเดือน
-- มีเลขที่เอกสารและสถานะการชำระของตัวเอง ไม่ผูกกับ ym ของรอบบิลปกติ
CREATE TABLE IF NOT EXISTS adhoc_bills (
  id           TEXT PRIMARY KEY,
  case_id      TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  bill_date    TEXT NOT NULL,   -- วันที่ออกบิล (YYYY-MM-DD)
  note         TEXT,            -- หัวข้อ/หมายเหตุของบิลนี้ เช่น "ค่าเวชภัณฑ์กลางเดือน"
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

-- ตัวนับเลขที่เอกสารแบบรันต่อเนื่อง แยกตามสาขา (branch_id), ประเภทเอกสาร (doc_type: 'invoice'|'receipt') และปี พ.ศ. ที่ออกเอกสาร
-- รีเซ็ตกลับเป็น 1 อัตโนมัติทุกปี เพราะแต่ละปีจะมีแถวของตัวเองในตารางนี้ (last_seq เริ่มที่ 1 เมื่อมีการออกเอกสารแรกของปีนั้น)
CREATE TABLE IF NOT EXISTS doc_sequences (
  branch_id TEXT NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  doc_type  TEXT NOT NULL,   -- 'invoice' | 'receipt'
  year      INTEGER NOT NULL,   -- ปี พ.ศ.
  last_seq  INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (branch_id, doc_type, year)
);

-- นัดหมอของแต่ละเคส แสดงในปฏิทินครบกำหนด — ใช้เตือนให้ลงค่าใช้จ่ายค่าบริการพาไปพบแพทย์หลังถึงวันนัด
CREATE TABLE IF NOT EXISTS appointments (
  id      TEXT PRIMARY KEY,
  case_id TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  date    TEXT NOT NULL,   -- วันนัด (YYYY-MM-DD)
  note    TEXT,            -- รายละเอียดนัด เช่น "พบแพทย์ตรวจตา"
  status  TEXT NOT NULL DEFAULT 'scheduled'   -- 'scheduled' | 'cancelled' (ยกเลิกแล้วยังเก็บประวัติไว้ ไม่ลบ)
);
CREATE INDEX IF NOT EXISTS idx_appointments_case ON appointments(case_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(date);
