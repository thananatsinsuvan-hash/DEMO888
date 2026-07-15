/**
 * สร้างผู้ใช้งานใหม่ — คำนวณรหัสผ่านแบบ PBKDF2 (ตรงกับที่ Worker ใช้ตรวจสอบตอนล็อกอิน)
 * แล้วพิมพ์คำสั่ง SQL ออกมาให้ก็อปไปรันกับ D1
 *
 * วิธีใช้:
 *   node scripts/create-user.js <username> <password> <displayName> <role: admin|staff> [orgId] [branchId]
 *
 * ตัวอย่าง (แอดมิน เข้าถึงได้ทุกสาขา):
 *   node scripts/create-user.js somsri "P@ssw0rd123" "สมศรี ใจดี" admin
 *
 * ตัวอย่าง (พนักงานสาขา ผูกกับ org/branch ที่มีอยู่แล้วใน D1):
 *   node scripts/create-user.js somchai "P@ssw0rd456" "สมชาย มั่นคง" staff org_abc123 branch_xyz789
 *
 * หา orgId / branchId ได้จาก:
 *   wrangler d1 execute care-billing-db --remote --command="SELECT id,name FROM orgs"
 *   wrangler d1 execute care-billing-db --remote --command="SELECT id,name,org_id FROM branches"
 */
const crypto = require('crypto');

const [, , username, password, displayName, role, orgId, branchId] = process.argv;

if (!username || !password || !displayName || !role) {
  console.error(
    'ใช้งาน: node scripts/create-user.js <username> <password> <displayName> <role: admin|staff> [orgId] [branchId]'
  );
  process.exit(1);
}
if (role !== 'admin' && role !== 'staff') {
  console.error('role ต้องเป็น admin หรือ staff เท่านั้น');
  process.exit(1);
}
if (role === 'staff' && (!orgId || !branchId)) {
  console.error('ผู้ใช้ role staff ต้องระบุ orgId และ branchId ด้วย (หาได้จากคำสั่งใน comment ด้านบนของไฟล์นี้)');
  process.exit(1);
}

const id = 'user_' + crypto.randomBytes(8).toString('hex');
const salt = crypto.randomBytes(16).toString('hex');
const hash = crypto.pbkdf2Sync(password, Buffer.from(salt, 'hex'), 100000, 32, 'sha256').toString('hex');

const esc = (s) => (s || '').replace(/'/g, "''");
const orgVal = orgId ? `'${esc(orgId)}'` : 'NULL';
const branchVal = branchId ? `'${esc(branchId)}'` : 'NULL';

const sql = `INSERT INTO users (id, username, password_hash, salt, display_name, role, org_id, branch_id)
VALUES ('${id}', '${esc(username)}', '${hash}', '${salt}', '${esc(displayName)}', '${role}', ${orgVal}, ${branchVal});`;

console.log('\n-- คัดลอก SQL ด้านล่างไปบันทึกในไฟล์ เช่น seed-users.sql แล้วรัน:');
console.log('--   wrangler d1 execute care-billing-db --remote --file=./seed-users.sql\n');
console.log(sql);
console.log('');
