-- Migration: เพิ่มชื่อพนักงานที่พาเคสไปหาหมอ ในตารางนัดหมาย
-- รันก่อน deploy โค้ดเวอร์ชันใหม่ ปลอดภัย ไม่กระทบข้อมูลเดิม

ALTER TABLE appointments ADD COLUMN staff_name TEXT NOT NULL DEFAULT '';
