-- Migration: จัดการเคสที่ย้ายออก (เก็บวันที่ย้ายออก แยกออกจากรายการเคสที่ใช้งานอยู่)
-- ใช้กับฐานข้อมูลที่ deploy ไปแล้วเท่านั้น
-- รันครั้งเดียว: wrangler d1 execute care-billing-db --remote --file=./migrations/008_case_moveout.sql

ALTER TABLE cases ADD COLUMN moved_out INTEGER NOT NULL DEFAULT 0;
ALTER TABLE cases ADD COLUMN move_out_date TEXT;
