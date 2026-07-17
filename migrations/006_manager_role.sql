-- Migration: เพิ่มบทบาท manager (เข้าถึงได้หลายสาขาตามที่ admin อนุญาต)
-- ใช้กับฐานข้อมูลที่ deploy ไปแล้วเท่านั้น (ฐานข้อมูลใหม่จะได้ตารางนี้จาก schema.sql อยู่แล้ว)
-- รันครั้งเดียว: wrangler d1 execute care-billing-db --remote --file=./migrations/006_manager_role.sql
-- หมายเหตุ: คอลัมน์ role ในตาราง users เป็น TEXT อยู่แล้ว ไม่ต้องแก้ไขคอลัมน์ ใช้ค่า 'manager' ได้ทันที

CREATE TABLE IF NOT EXISTS user_branch_access (
  user_id   TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  branch_id TEXT NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, branch_id)
);
CREATE INDEX IF NOT EXISTS idx_user_branch_access_user   ON user_branch_access(user_id);
CREATE INDEX IF NOT EXISTS idx_user_branch_access_branch ON user_branch_access(branch_id);
