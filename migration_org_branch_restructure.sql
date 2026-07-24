-- Migration: ปรับโครงสร้างองค์กร/สาขา
-- - เพิ่มเบอร์โทรศัพท์ให้องค์กร
-- - ย้ายโลโก้และหมายเหตุท้ายบิลจากองค์กรมาไว้ที่สาขา
-- รันก่อน deploy โค้ดเวอร์ชันใหม่ ปลอดภัย ไม่กระทบข้อมูลเดิม (คอลัมน์เก่าของ orgs เช่น company_name, logo, logo_key, note
-- จะยังอยู่ในฐานข้อมูล แค่โค้ดใหม่ไม่ได้ใช้แล้วเท่านั้น ไม่ต้องลบออก)

ALTER TABLE orgs ADD COLUMN phone TEXT NOT NULL DEFAULT '';

ALTER TABLE branches ADD COLUMN logo TEXT NOT NULL DEFAULT '';
ALTER TABLE branches ADD COLUMN logo_key TEXT NOT NULL DEFAULT '';
ALTER TABLE branches ADD COLUMN note TEXT NOT NULL DEFAULT '';

-- ย้ายข้อมูลโลโก้/หมายเหตุเดิมจากองค์กร ไปให้ทุกสาขาในองค์กรนั้น (ค่าเริ่มต้นให้ทุกสาขา แก้ไขทีหลังได้ที่ฟอร์มสาขา)
UPDATE branches
SET logo = (SELECT logo FROM orgs WHERE orgs.id = branches.org_id),
    logo_key = (SELECT logo_key FROM orgs WHERE orgs.id = branches.org_id),
    note = (SELECT note FROM orgs WHERE orgs.id = branches.org_id)
WHERE EXISTS (SELECT 1 FROM orgs WHERE orgs.id = branches.org_id AND (orgs.logo != '' OR orgs.logo_key != '' OR orgs.note != ''));
