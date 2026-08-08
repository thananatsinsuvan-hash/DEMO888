-- Migration: เพิ่มเลขที่เตียงให้เคส
-- รันก่อน deploy โค้ดเวอร์ชันใหม่ ปลอดภัย ไม่กระทบข้อมูลเดิม

ALTER TABLE cases ADD COLUMN bed_number TEXT NOT NULL DEFAULT '';
