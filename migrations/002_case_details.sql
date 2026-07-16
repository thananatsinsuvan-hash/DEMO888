-- Migration: เพิ่มข้อมูลประวัติเบื้องต้น + วันที่เข้ารับบริการ + รูปคนไข้ ในตาราง cases
-- ใช้กับฐานข้อมูลที่ deploy ไปแล้วเท่านั้น (ฐานข้อมูลใหม่จะได้คอลัมน์เหล่านี้จาก schema.sql อยู่แล้ว)
-- รันครั้งเดียว: wrangler d1 execute care-billing-db --remote --file=./migrations/002_case_details.sql

ALTER TABLE cases ADD COLUMN age INTEGER;
ALTER TABLE cases ADD COLUMN health_info TEXT;
ALTER TABLE cases ADD COLUMN allergy TEXT;
ALTER TABLE cases ADD COLUMN emergency_contact TEXT;
ALTER TABLE cases ADD COLUMN emergency_phone TEXT;
ALTER TABLE cases ADD COLUMN admission_date TEXT;
ALTER TABLE cases ADD COLUMN photo_key TEXT;
