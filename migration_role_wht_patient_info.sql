-- Migration: รวมสำหรับฟีเจอร์ชุดนี้ (role ผู้ลงบัญชี ไม่ต้องแก้ schema เพราะ role เก็บเป็น TEXT อยู่แล้ว,
-- ข้อมูลบริษัทในองค์กร, หัก ณ ที่จ่าย, ข้อมูลคนไข้เพิ่มเติม)
-- รันก่อน deploy โค้ดเวอร์ชันใหม่ ปลอดภัย ไม่กระทบข้อมูลเดิม ค่าเริ่มต้นทุกคอลัมน์ทำให้พฤติกรรมเดิมไม่เปลี่ยน

-- ข้อมูลบริษัทในองค์กร (ถ้ายังไม่เคยรัน migration_org_company_info.sql มาก่อน)
ALTER TABLE orgs ADD COLUMN company_name TEXT NOT NULL DEFAULT '';
ALTER TABLE orgs ADD COLUMN tax_id TEXT NOT NULL DEFAULT '';
ALTER TABLE orgs ADD COLUMN address TEXT NOT NULL DEFAULT '';

-- หัก ณ ที่จ่าย: ค่าเริ่มต้นระดับบัญชีธนาคาร
ALTER TABLE bank_accounts ADD COLUMN withholding_tax TEXT NOT NULL DEFAULT 'none';

-- ข้อมูลคนไข้เพิ่มเติม + override หัก ณ ที่จ่ายระดับเคส
ALTER TABLE cases ADD COLUMN withholding_override TEXT NOT NULL DEFAULT '';
ALTER TABLE cases ADD COLUMN address TEXT NOT NULL DEFAULT '';
ALTER TABLE cases ADD COLUMN phone TEXT NOT NULL DEFAULT '';
ALTER TABLE cases ADD COLUMN tax_id TEXT NOT NULL DEFAULT '';
