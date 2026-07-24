/**
 * ระบบบันทึกค่าใช้จ่ายผู้สูงอายุ — Cloudflare Worker API (มีระบบ login + สิทธิ์ตามสาขา)
 *
 * Endpoints:
 *   POST /api/login    { username, password } -> ตั้ง session cookie
 *   POST /api/logout   -> ล้าง session cookie
 *   GET  /api/me       -> ข้อมูลผู้ใช้ปัจจุบัน
 *   GET  /api/state    -> โหลดข้อมูล (admin เห็นทั้งหมด, staff เห็นเฉพาะสาขาตัวเอง)
 *   POST /api/state    -> บันทึกข้อมูล (admin บันทึกได้ทั้งหมด, staff บันทึกได้เฉพาะสาขาตัวเอง)
 *   POST /api/cases/:id/photo        -> อัปโหลดรูปคนไข้
 *   POST /api/orgs/:id/logo          -> อัปโหลดโลโก้องค์กร (admin เท่านั้น)
 *   POST /api/branches/:id/signature -> อัปโหลดรูปลายเซ็นเจ้าหน้าที่ของสาขา (admin เท่านั้น)
 *   POST /api/payments/:caseId/:ym/slip -> อัปโหลดรูปสลิปโอนเงิน/หลักฐานรับเงินสด (บิลรายเดือน)
 *   POST /api/adhoc-bills/:billId/slip  -> อัปโหลดรูปสลิปโอนเงิน/หลักฐานรับเงินสด (บิลพิเศษระหว่างเดือน)
 *   GET  /api/photo/:key             -> ดึงไฟล์รูปจาก R2
 *   POST /api/doc-number              -> ออกเลขที่เอกสาร (invoice/receipt) แบบรันต่อเนื่อง แยกตามสาขา รีเซ็ตทุกปี
 *
 * ต้องตั้งค่า secret ก่อนใช้งาน:
 *   wrangler secret put SESSION_SECRET
 */

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};
const SESSION_MAX_AGE = 60 * 60 * 24 * 7; // 7 วัน

function json(data, status = 200, extraHeaders = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json", ...CORS_HEADERS, ...extraHeaders },
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "OPTIONS") return new Response(null, { headers: CORS_HEADERS });

    try {
      if (url.pathname === "/api/login" && request.method === "POST") return await handleLogin(request, env);
      if (url.pathname === "/api/logout" && request.method === "POST") return handleLogout();
      if (url.pathname === "/api/me" && request.method === "GET") return await handleMe(request, env);

      if (url.pathname === "/api/state") {
        const user = await getUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);

        if (request.method === "GET") {
          const state =
            user.role === "admin" ? await loadState(env.DB) : await loadScopedState(env.DB, await getAccessibleBranchIds(env.DB, user));
          return json(state);
        }
        if (request.method === "POST") {
          const body = await request.json();
          if (user.role === "admin") {
            await saveState(env.DB, body);
          } else {
            await saveScopedState(env.DB, body, await getAccessibleBranchIds(env.DB, user));
          }
          return json({ ok: true });
        }
      }

      if (url.pathname === "/api/doc-number" && request.method === "POST") {
        const user = await getUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);
        return await handleDocNumber(request, env, user);
      }

      if (url.pathname === "/api/users" || url.pathname.startsWith("/api/users/")) {
        const user = await getUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);
        if (user.role !== "admin") return json({ error: "forbidden — เฉพาะผู้ดูแลระบบเท่านั้น" }, 403);
        return await handleUsers(request, env, url, user);
      }

      if (url.pathname.startsWith("/api/cases/") && url.pathname.endsWith("/photo") && request.method === "POST") {
        const user = await getUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);
        const parts = url.pathname.split("/").filter(Boolean); // ["api","cases",caseId,"photo"]
        const caseId = parts[2];
        if (user.role !== "admin") {
          const ok = await userOwnsCase(env.DB, await getAccessibleBranchIds(env.DB, user), caseId);
          if (!ok) return json({ error: "forbidden — เคสนี้ไม่ได้อยู่ในสาขาที่คุณเข้าถึงได้" }, 403);
        }
        return await handleUploadPhoto(request, env, `${caseId}-`);
      }

      if (url.pathname.startsWith("/api/orgs/") && url.pathname.endsWith("/logo") && request.method === "POST") {
        const user = await getUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);
        if (user.role !== "admin") return json({ error: "forbidden — เฉพาะผู้ดูแลระบบเท่านั้น" }, 403);
        const parts = url.pathname.split("/").filter(Boolean); // ["api","orgs",orgId,"logo"]
        return await handleUploadPhoto(request, env, `org-${parts[2]}-`);
      }

      if (url.pathname.startsWith("/api/branches/") && url.pathname.endsWith("/logo") && request.method === "POST") {
        const user = await getUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);
        if (user.role !== "admin") return json({ error: "forbidden — เฉพาะผู้ดูแลระบบเท่านั้น" }, 403);
        const parts = url.pathname.split("/").filter(Boolean); // ["api","branches",branchId,"logo"]
        return await handleUploadPhoto(request, env, `branch-logo-${parts[2]}-`);
      }

      if (url.pathname.startsWith("/api/branches/") && url.pathname.endsWith("/signature") && request.method === "POST") {
        const user = await getUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);
        if (user.role !== "admin") return json({ error: "forbidden — เฉพาะผู้ดูแลระบบเท่านั้น" }, 403);
        const parts = url.pathname.split("/").filter(Boolean); // ["api","branches",branchId,"signature"]
        return await handleUploadPhoto(request, env, `branch-sig-${parts[2]}-`);
      }

      if (url.pathname.startsWith("/api/payments/") && url.pathname.endsWith("/slip") && request.method === "POST") {
        const user = await getUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);
        const parts = url.pathname.split("/").filter(Boolean); // ["api","payments",caseId,ym,"slip"]
        const caseId = parts[2];
        if (user.role !== "admin") {
          const ok = await userOwnsCase(env.DB, await getAccessibleBranchIds(env.DB, user), caseId);
          if (!ok) return json({ error: "forbidden — เคสนี้ไม่ได้อยู่ในสาขาที่คุณเข้าถึงได้" }, 403);
        }
        return await handleUploadPhoto(request, env, `slip-${caseId}-${parts[3]}-`);
      }

      if (url.pathname.startsWith("/api/adhoc-bills/") && url.pathname.endsWith("/slip") && request.method === "POST") {
        const user = await getUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);
        const parts = url.pathname.split("/").filter(Boolean); // ["api","adhoc-bills",billId,"slip"]
        const billId = parts[2];
        if (user.role !== "admin") {
          const ok = await userOwnsAdhocBill(env.DB, await getAccessibleBranchIds(env.DB, user), billId);
          if (!ok) return json({ error: "forbidden — บิลนี้ไม่ได้อยู่ในสาขาที่คุณเข้าถึงได้" }, 403);
        }
        return await handleUploadPhoto(request, env, `slip-adhoc-${billId}-`);
      }

      if (url.pathname.startsWith("/api/photo/") && request.method === "GET") {
        const user = await getUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);
        return await handleGetPhoto(request, env, url);
      }
    } catch (err) {
      return json({ error: String(err && err.message ? err.message : err) }, 500);
    }

    if (env.ASSETS) return env.ASSETS.fetch(request);
    return new Response("Not found", { status: 404, headers: CORS_HEADERS });
  },
};

/* ================= AUTH ================= */

async function handleLogin(request, env) {
  const { username, password } = await request.json();
  if (!username || !password) return json({ error: "กรุณากรอกชื่อผู้ใช้และรหัสผ่าน" }, 400);

  const row = await env.DB.prepare("SELECT * FROM users WHERE username = ?").bind(username).first();
  if (!row) return json({ error: "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง" }, 401);

  const hash = await hashPassword(password, row.salt);
  if (hash !== row.password_hash) return json({ error: "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง" }, 401);

  const payload = {
    uid: row.id,
    username: row.username,
    role: row.role,
    orgId: row.org_id || "",
    branchId: row.branch_id || "",
    displayName: row.display_name || row.username,
    exp: Date.now() + SESSION_MAX_AGE * 1000,
  };
  const token = await createSessionToken(payload, env.SESSION_SECRET);
  const cookie = `session=${token}; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=${SESSION_MAX_AGE}`;
  return json(
    { ok: true, user: { username: payload.username, role: payload.role, displayName: payload.displayName, orgId: payload.orgId, branchId: payload.branchId } },
    200,
    { "Set-Cookie": cookie }
  );
}

function handleLogout() {
  const cookie = `session=; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=0`;
  return json({ ok: true }, 200, { "Set-Cookie": cookie });
}

async function handleMe(request, env) {
  const user = await getUser(request, env);
  if (!user) return json({ error: "unauthorized" }, 401);
  return json({ username: user.username, role: user.role, displayName: user.displayName, orgId: user.orgId, branchId: user.branchId });
}

async function getUser(request, env) {
  const token = getCookie(request, "session");
  if (!token) return null;
  return await verifySessionToken(token, env.SESSION_SECRET);
}

function getCookie(request, name) {
  const cookieHeader = request.headers.get("Cookie") || "";
  const match = cookieHeader.match(new RegExp("(?:^|;\\s*)" + name + "=([^;]*)"));
  return match ? decodeURIComponent(match[1]) : null;
}

/* ================= USER MANAGEMENT (admin only) ================= */

async function handleUsers(request, env, url, currentUser) {
  const parts = url.pathname.split("/").filter(Boolean); // ["api","users", ...]

  // GET /api/users — รายชื่อผู้ใช้ทั้งหมด (ไม่ส่ง password_hash/salt กลับ) พร้อมสาขาที่ staff/manager เข้าถึงได้
  if (parts.length === 2 && request.method === "GET") {
    const rows = (await env.DB.prepare("SELECT id,username,display_name,role,org_id,branch_id FROM users ORDER BY username").all()).results;
    const accessRows = (await env.DB.prepare("SELECT user_id, branch_id FROM user_branch_access").all()).results;
    const accessByUser = {};
    for (const a of accessRows) (accessByUser[a.user_id] ||= []).push(a.branch_id);
    return json({ users: rows.map((r) => mapUserRow(r, accessByUser[r.id])) });
  }

  // POST /api/users — สร้างผู้ใช้ใหม่
  if (parts.length === 2 && request.method === "POST") {
    return await createUser(request, env);
  }

  // DELETE /api/users/:id — ลบผู้ใช้
  if (parts.length === 3 && request.method === "DELETE") {
    const id = parts[2];
    if (id === currentUser.uid) return json({ error: "ไม่สามารถลบบัญชีที่กำลังใช้งานอยู่ได้" }, 400);
    const existing = await env.DB.prepare("SELECT id FROM users WHERE id = ?").bind(id).first();
    if (!existing) return json({ error: "ไม่พบผู้ใช้นี้" }, 404);
    await env.DB.prepare("DELETE FROM users WHERE id = ?").bind(id).run();
    return json({ ok: true });
  }

  // POST /api/users/:id/reset-password — รีเซ็ตรหัสผ่าน
  if (parts.length === 4 && parts[3] === "reset-password" && request.method === "POST") {
    const id = parts[2];
    const body = await request.json().catch(() => ({}));
    const password = body.password;
    if (!password || password.length < 6) return json({ error: "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร" }, 400);
    const existing = await env.DB.prepare("SELECT id FROM users WHERE id = ?").bind(id).first();
    if (!existing) return json({ error: "ไม่พบผู้ใช้นี้" }, 404);
    const salt = generateSaltHex();
    const hash = await hashPassword(password, salt);
    await env.DB.prepare("UPDATE users SET password_hash = ?, salt = ? WHERE id = ?").bind(hash, salt, id).run();
    return json({ ok: true });
  }

  // POST /api/users/:id/access — กำหนดสาขาที่ staff/manager คนนี้เข้าถึงได้ (แทนที่ทั้งหมด)
  if (parts.length === 4 && parts[3] === "access" && request.method === "POST") {
    const id = parts[2];
    const body = await request.json().catch(() => ({}));
    const branchIds = Array.isArray(body.branchIds) ? body.branchIds : [];
    const existing = await env.DB.prepare("SELECT id, role FROM users WHERE id = ?").bind(id).first();
    if (!existing) return json({ error: "ไม่พบผู้ใช้นี้" }, 404);
    if (existing.role !== "manager" && existing.role !== "staff") {
      return json({ error: "กำหนดสิทธิ์สาขาได้เฉพาะผู้ใช้ role manager หรือ staff เท่านั้น" }, 400);
    }

    if (branchIds.length) {
      const placeholders = branchIds.map(() => "?").join(",");
      const validRows = (await env.DB.prepare(`SELECT id FROM branches WHERE id IN (${placeholders})`).bind(...branchIds).all()).results;
      if (validRows.length !== new Set(branchIds).size) return json({ error: "มีสาขาที่เลือกไม่ถูกต้อง" }, 400);
    }

    const stmts = [env.DB.prepare("DELETE FROM user_branch_access WHERE user_id = ?").bind(id)];
    for (const branchId of branchIds) {
      stmts.push(env.DB.prepare("INSERT INTO user_branch_access (user_id, branch_id) VALUES (?,?)").bind(id, branchId));
    }
    await env.DB.batch(stmts);
    return json({ ok: true });
  }

  return json({ error: "not found" }, 404);
}

function mapUserRow(r, branchIds) {
  return {
    id: r.id,
    username: r.username,
    displayName: r.display_name || "",
    role: r.role,
    orgId: r.org_id || "",
    branchId: r.branch_id || "",
    branchIds: r.role === "manager" || r.role === "staff" || r.role === "accountant" ? branchIds || [] : undefined,
  };
}

// staff และ manager ใช้กลไกเดียวกัน: เลือกได้หลายสาขา กำหนดโดย admin ผ่านตาราง user_branch_access
async function createUser(request, env) {
  const body = await request.json().catch(() => ({}));
  const { username, password, displayName, role, orgId, branchId, branchIds } = body;

  if (!username || !password || !displayName || !role) return json({ error: "กรุณากรอกข้อมูลให้ครบ" }, 400);
  if (role !== "admin" && role !== "manager" && role !== "staff" && role !== "accountant") return json({ error: "role ต้องเป็น admin, manager, staff หรือ accountant เท่านั้น" }, 400);
  if (password.length < 6) return json({ error: "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร" }, 400);
  if ((role === "manager" || role === "staff" || role === "accountant") && (!Array.isArray(branchIds) || branchIds.length === 0)) {
    return json({ error: `ผู้ใช้ role ${role} ต้องเลือกสาขาที่เข้าถึงได้อย่างน้อย 1 สาขา` }, 400);
  }

  const usernameTaken = await env.DB.prepare("SELECT id FROM users WHERE username = ?").bind(username).first();
  if (usernameTaken) return json({ error: "ชื่อผู้ใช้นี้ถูกใช้แล้ว" }, 400);

  if (role === "manager" || role === "staff" || role === "accountant") {
    const placeholders = branchIds.map(() => "?").join(",");
    const validRows = (await env.DB.prepare(`SELECT id FROM branches WHERE id IN (${placeholders})`).bind(...branchIds).all()).results;
    if (validRows.length !== new Set(branchIds).size) return json({ error: "มีสาขาที่เลือกไม่ถูกต้อง" }, 400);
  }

  const id = "user_" + generateHex(8);
  const salt = generateSaltHex();
  const hash = await hashPassword(password, salt);

  // org_id/branch_id เดี่ยว (คอลัมน์เก่า) ไม่ใช้กับผู้ใช้ที่สร้างใหม่แล้ว — เก็บไว้เพื่อความเข้ากันได้กับบัญชี staff เก่าที่สร้างไว้ก่อนหน้านี้เท่านั้น
  const stmts = [
    env.DB
      .prepare("INSERT INTO users (id, username, password_hash, salt, display_name, role, org_id, branch_id) VALUES (?,?,?,?,?,?,?,?)")
      .bind(id, username, hash, salt, displayName, role, null, null),
  ];
  if (role === "manager" || role === "staff" || role === "accountant") {
    for (const bId of branchIds) {
      stmts.push(env.DB.prepare("INSERT INTO user_branch_access (user_id, branch_id) VALUES (?,?)").bind(id, bId));
    }
  }
  await env.DB.batch(stmts);

  return json({ ok: true, id });
}

function generateHex(numBytes) {
  const bytes = new Uint8Array(numBytes);
  crypto.getRandomValues(bytes);
  return bytesToHex(bytes);
}
function generateSaltHex() {
  return generateHex(16);
}

/* ================= PATIENT PHOTOS (R2) ================= */

const MAX_PHOTO_BYTES = 5 * 1024 * 1024; // 5MB

async function handleUploadPhoto(request, env, keyPrefix) {
  if (!keyPrefix) return json({ error: "ไม่พบรหัสอ้างอิง" }, 400);
  if (!env.PHOTOS) return json({ error: "ยังไม่ได้ตั้งค่า R2 bucket สำหรับเก็บรูปภาพ (ดูคำแนะนำใน README)" }, 500);

  const contentType = request.headers.get("Content-Type") || "";
  if (!contentType.startsWith("image/")) return json({ error: "รองรับเฉพาะไฟล์รูปภาพเท่านั้น" }, 400);

  const buf = await request.arrayBuffer();
  if (buf.byteLength === 0) return json({ error: "ไฟล์รูปว่างเปล่า" }, 400);
  if (buf.byteLength > MAX_PHOTO_BYTES) return json({ error: "ไฟล์รูปใหญ่เกินไป (จำกัด 5MB)" }, 400);

  const ext = (contentType.split("/")[1] || "jpg").split("+")[0].replace(/[^a-z0-9]/gi, "").toLowerCase() || "jpg";
  const key = `${keyPrefix}${Date.now()}.${ext}`;

  await env.PHOTOS.put(key, buf, { httpMetadata: { contentType } });

  return json({ ok: true, key });
}

// รายชื่อสาขาที่ผู้ใช้เข้าถึงได้ — staff และ manager เข้าถึงได้ตามสาขาที่ admin อนุญาตในตาราง user_branch_access (เลือกได้หลายสาขาเหมือนกันทั้งสองบทบาท)
// ถ้าเป็นบัญชี staff เก่าที่ยังไม่เคยกำหนดผ่านตารางนี้ (สร้างไว้ตั้งแต่ก่อนมีฟีเจอร์นี้) จะ fallback ไปใช้ branch_id เดี่ยวที่ผูกไว้แต่เดิมแทน
// admin: ไม่เรียกใช้ฟังก์ชันนี้ (เข้าถึงได้ทั้งหมดอยู่แล้ว)
async function getAccessibleBranchIds(db, user) {
  if (user.role === "manager" || user.role === "staff" || user.role === "accountant") {
    const rows = (await db.prepare("SELECT branch_id FROM user_branch_access WHERE user_id = ?").bind(user.uid).all()).results;
    if (rows.length) return rows.map((r) => r.branch_id);
  }
  return user.branchId ? [user.branchId] : [];
}

// ตรวจว่าเคสที่ระบุอยู่ในสาขาที่ผู้ใช้เข้าถึงได้จริงหรือไม่ (ป้องกันอัปโหลดข้ามสาขา)
async function userOwnsCase(db, accessibleBranchIds, caseId) {
  if (!accessibleBranchIds || !accessibleBranchIds.length || !caseId) return false;
  const placeholders = accessibleBranchIds.map(() => "?").join(",");
  const row = await db.prepare(`SELECT id FROM cases WHERE id = ? AND branch_id IN (${placeholders})`).bind(caseId, ...accessibleBranchIds).first();
  return !!row;
}

// ตรวจว่าบิลพิเศษที่ระบุ ผูกกับเคสในสาขาที่ผู้ใช้เข้าถึงได้จริงหรือไม่
async function userOwnsAdhocBill(db, accessibleBranchIds, billId) {
  if (!accessibleBranchIds || !accessibleBranchIds.length || !billId) return false;
  const placeholders = accessibleBranchIds.map(() => "?").join(",");
  const row = await db
    .prepare(`SELECT ab.id FROM adhoc_bills ab JOIN cases c ON c.id = ab.case_id WHERE ab.id = ? AND c.branch_id IN (${placeholders})`)
    .bind(billId, ...accessibleBranchIds)
    .first();
  return !!row;
}

/* ================= เลขที่เอกสารรันอัตโนมัติ (แยกตามสาขา, แยกชุด invoice/receipt, รีเซ็ตทุกปี พ.ศ.) ================= */

// ปี พ.ศ. ของวันที่ที่ระบุ (ใช้เป็นตัวรีเซ็ตเลขรันทุกปี)
function beYear(date) {
  return date.getFullYear() + 543;
}

// รหัสสาขาที่ใช้ประกอบเลขที่เอกสาร — ใช้รหัสที่ admin ตั้งไว้ ถ้าไม่ได้ตั้งจะ derive จาก branch id แทน (สั้น อ่านง่าย)
function branchDocCode(branch) {
  if (branch && branch.code && branch.code.trim()) return branch.code.trim().toUpperCase().replace(/\s+/g, "");
  const id = (branch && branch.id) || "br";
  return "BR" + id.replace(/[^a-zA-Z0-9]/g, "").slice(-4).toUpperCase();
}

// จองเลขรันถัดไปของสาขา/ประเภทเอกสาร/ปีนั้น แบบ atomic (กันเลขซ้ำแม้มีการออกเอกสารพร้อมกัน)
// bankAccountKey ว่าง ("") = ใช้ชุดเลขหลักของสาขา (ปกติ) — ถ้าระบุ = แยกชุดเลขเฉพาะของบัญชีนั้น ไม่ปนกับชุดหลัก
async function allocateDocSeq(db, branchId, docType, year, bankAccountKey = "") {
  const row = await db
    .prepare(
      `INSERT INTO doc_sequences (branch_id, doc_type, year, bank_account_id, last_seq) VALUES (?,?,?,?,1)
       ON CONFLICT(branch_id, doc_type, year, bank_account_id) DO UPDATE SET last_seq = last_seq + 1
       RETURNING last_seq`
    )
    .bind(branchId, docType, year, bankAccountKey || "")
    .first();
  return row.last_seq;
}

// เช็คว่าบัญชีธนาคารที่เคสนี้ผูกไว้ ตั้งค่าการออกเลขที่เอกสารแบบไหน ("shared" ถ้าไม่ได้ผูกบัญชี หรือไม่พบบัญชี)
async function getDocNumberingMode(db, bankAccountId) {
  if (!bankAccountId) return "shared";
  const row = await db.prepare("SELECT doc_numbering FROM bank_accounts WHERE id = ?").bind(bankAccountId).first();
  return (row && row.doc_numbering) || "shared";
}

function formatDocNo(docType, branch, year, seq) {
  const prefix = docType === "receipt" ? "RCT" : "INV";
  return `${prefix}-${branchDocCode(branch)}-${year}-${String(seq).padStart(4, "0")}`;
}

// ออกเลขที่เอกสารให้เคส/บิลที่ระบุ — คืนเลขเดิมถ้าเคยออกแล้ว ไม่งั้นจองเลขใหม่และบันทึกถาวรลงแถวนั้นเลย
async function handleDocNumber(request, env, user) {
  const body = await request.json().catch(() => ({}));
  const { kind, caseId, ym, billId } = body;
  if (!["monthly-invoice", "monthly-receipt", "adhoc-invoice", "adhoc-receipt"].includes(kind)) {
    return json({ error: "kind ไม่ถูกต้อง" }, 400);
  }

  const accessibleBranchIds = user.role === "admin" ? null : await getAccessibleBranchIds(env.DB, user);

  if (kind === "monthly-invoice" || kind === "monthly-receipt") {
    if (!caseId || !ym) return json({ error: "ต้องระบุ caseId และ ym" }, 400);
    if (accessibleBranchIds) {
      const ok = await userOwnsCase(env.DB, accessibleBranchIds, caseId);
      if (!ok) return json({ error: "forbidden — เคสนี้ไม่ได้อยู่ในสาขาที่คุณเข้าถึงได้" }, 403);
    }
    const caseRow = await env.DB.prepare("SELECT branch_id, bank_account_id FROM cases WHERE id = ?").bind(caseId).first();
    if (!caseRow || !caseRow.branch_id) return json({ error: "เคสนี้ยังไม่ได้ระบุสาขา ไม่สามารถออกเลขที่เอกสารได้" }, 400);
    const branch = await env.DB.prepare("SELECT * FROM branches WHERE id = ?").bind(caseRow.branch_id).first();
    const docType = kind === "monthly-invoice" ? "invoice" : "receipt";
    const col = docType === "invoice" ? "invoice_no" : "receipt_no";

    await env.DB.prepare("INSERT OR IGNORE INTO payments (case_id, ym) VALUES (?,?)").bind(caseId, ym).run();
    const existing = await env.DB.prepare(`SELECT ${col} AS no FROM payments WHERE case_id = ? AND ym = ?`).bind(caseId, ym).first();
    if (existing && existing.no) return json({ number: existing.no });

    // บัญชีธนาคารที่เคสนี้ผูกไว้ตั้งเป็น "ไม่ต้องออกเลขที่เอกสาร" — คืนเลขว่าง ไม่บันทึก ไม่แตะตัวนับ
    const numberingMode = await getDocNumberingMode(env.DB, caseRow.bank_account_id);
    if (numberingMode === "none") return json({ number: "" });

    const year = beYear(new Date());
    const seq = await allocateDocSeq(env.DB, branch.id, docType, year, numberingMode === "separate" ? caseRow.bank_account_id : "");
    const number = formatDocNo(docType, mapBranch(branch), year, seq);
    await env.DB.prepare(`UPDATE payments SET ${col} = ? WHERE case_id = ? AND ym = ?`).bind(number, caseId, ym).run();
    return json({ number });
  }

  // adhoc-invoice / adhoc-receipt
  if (!billId) return json({ error: "ต้องระบุ billId" }, 400);
  if (accessibleBranchIds) {
    const ok = await userOwnsAdhocBill(env.DB, accessibleBranchIds, billId);
    if (!ok) return json({ error: "forbidden — บิลนี้ไม่ได้อยู่ในสาขาที่คุณเข้าถึงได้" }, 403);
  }
  const billRow = await env.DB
    .prepare(`SELECT ab.*, c.branch_id AS branch_id, c.bank_account_id AS bank_account_id FROM adhoc_bills ab JOIN cases c ON c.id = ab.case_id WHERE ab.id = ?`)
    .bind(billId)
    .first();
  if (!billRow || !billRow.branch_id) return json({ error: "ไม่พบบิลนี้ หรือเคสยังไม่ได้ระบุสาขา" }, 400);
  const branch = await env.DB.prepare("SELECT * FROM branches WHERE id = ?").bind(billRow.branch_id).first();
  const docType = kind === "adhoc-invoice" ? "invoice" : "receipt";
  const col = docType === "invoice" ? "invoice_no" : "receipt_no";

  if (billRow[col]) return json({ number: billRow[col] });

  // บัญชีธนาคารที่เคสนี้ผูกไว้ตั้งเป็น "ไม่ต้องออกเลขที่เอกสาร" — คืนเลขว่าง ไม่บันทึก ไม่แตะตัวนับ
  const numberingMode = await getDocNumberingMode(env.DB, billRow.bank_account_id);
  if (numberingMode === "none") return json({ number: "" });

  const year = beYear(new Date());
  const seq = await allocateDocSeq(env.DB, branch.id, docType, year, numberingMode === "separate" ? billRow.bank_account_id : "");
  const number = formatDocNo(docType, mapBranch(branch), year, seq);
  await env.DB.prepare(`UPDATE adhoc_bills SET ${col} = ? WHERE id = ?`).bind(number, billId).run();
  return json({ number });
}

async function handleGetPhoto(request, env, url) {
  if (!env.PHOTOS) return json({ error: "ยังไม่ได้ตั้งค่า R2 bucket สำหรับเก็บรูปภาพ" }, 500);
  const parts = url.pathname.split("/").filter(Boolean); // ["api","photo",key]
  const key = decodeURIComponent(parts.slice(2).join("/") || "");
  if (!key) return new Response("Not found", { status: 404 });

  const obj = await env.PHOTOS.get(key);
  if (!obj) return new Response("Not found", { status: 404 });

  const headers = new Headers();
  obj.writeHttpMetadata(headers);
  headers.set("Cache-Control", "private, max-age=3600");
  return new Response(obj.body, { headers });
}

/* ---- password hashing (PBKDF2-SHA256, ต้องตรงกับ scripts/create-user.js ) ---- */
async function hashPassword(password, saltHex) {
  const enc = new TextEncoder();
  const saltBytes = hexToBytes(saltHex);
  const keyMaterial = await crypto.subtle.importKey("raw", enc.encode(password), { name: "PBKDF2" }, false, ["deriveBits"]);
  const bits = await crypto.subtle.deriveBits({ name: "PBKDF2", salt: saltBytes, iterations: 100000, hash: "SHA-256" }, keyMaterial, 256);
  return bytesToHex(new Uint8Array(bits));
}

/* ---- session token: base64url(payload).base64url(HMAC-SHA256 signature) ---- */
async function createSessionToken(payload, secret) {
  const enc = new TextEncoder();
  const payloadB64 = base64url(enc.encode(JSON.stringify(payload)));
  const key = await crypto.subtle.importKey("raw", enc.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const sig = await crypto.subtle.sign("HMAC", key, enc.encode(payloadB64));
  return `${payloadB64}.${base64url(new Uint8Array(sig))}`;
}
async function verifySessionToken(token, secret) {
  const parts = token.split(".");
  if (parts.length !== 2) return null;
  const [payloadB64, sigB64] = parts;
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey("raw", enc.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["verify"]);
  const valid = await crypto.subtle.verify("HMAC", key, base64urlDecode(sigB64), enc.encode(payloadB64));
  if (!valid) return null;
  const payload = JSON.parse(new TextDecoder().decode(base64urlDecode(payloadB64)));
  if (payload.exp && Date.now() > payload.exp) return null;
  return payload;
}

function hexToBytes(hex) {
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < bytes.length; i++) bytes[i] = parseInt(hex.substr(i * 2, 2), 16);
  return bytes;
}
function bytesToHex(bytes) {
  return [...bytes].map((b) => b.toString(16).padStart(2, "0")).join("");
}
function base64url(bytes) {
  let str = "";
  for (const b of bytes) str += String.fromCharCode(b);
  return btoa(str).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}
function base64urlDecode(str) {
  str = str.replace(/-/g, "+").replace(/_/g, "/");
  while (str.length % 4) str += "=";
  const bin = atob(str);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes;
}

/* ================= DATA MAPPING ================= */

const mapOrg = (o) => ({ id: o.id, name: o.name, taxId: o.tax_id || "", address: o.address || "", phone: o.phone || "", staff: o.staff || "" });
const mapBranch = (b) => ({
  id: b.id,
  orgId: b.org_id,
  name: b.name,
  address: b.address || "",
  phone: b.phone || "",
  code: b.code || "",
  staff: b.staff || "",
  signatureKey: b.signature_key || "",
  logo: b.logo || "",
  logoKey: b.logo_key || "",
  note: b.note || "",
});
const mapBankAccount = (a) => ({
  id: a.id,
  branchId: a.branch_id,
  bankName: a.bank_name || "",
  bankAcc: a.bank_acc || "",
  bankOwner: a.bank_owner || "",
  docNumbering: a.doc_numbering || "shared", // "shared" = ใช้เลขร่วมกับสาขา, "separate" = แยกชุดเลขของบัญชีนี้, "none" = ไม่ต้องออกเลขที่เอกสาร
  withholdingTax: a.withholding_tax || "none", // "apply" = หัก ณ ที่จ่าย 3% เป็นค่าเริ่มต้นสำหรับเคสที่ใช้บัญชีนี้, "none" = ไม่หัก
});
const mapCase = (c) => ({
  id: c.id,
  branchId: c.branch_id || "",
  name: c.name,
  note: c.note || "",
  monthlyFee: c.monthly_fee,
  dueDay: c.due_day,
  bankName: c.bank_name || "",
  bankAcc: c.bank_acc || "",
  bankOwner: c.bank_owner || "",
  bankAccountId: c.bank_account_id || "",
  age: c.age ?? null,
  healthInfo: c.health_info || "",
  allergy: c.allergy || "",
  emergencyContact: c.emergency_contact || "",
  emergencyPhone: c.emergency_phone || "",
  admissionDate: c.admission_date || "",
  dueDateOverride: c.due_date_override || "",
  withholdingOverride: c.withholding_override || "",
  address: c.address || "",
  phone: c.phone || "",
  taxId: c.tax_id || "",
  photoKey: c.photo_key || "",
  movedOut: !!c.moved_out,
  moveOutDate: c.move_out_date || "",
});
const mapPayment = (p) => ({
  paid: !!p.paid,
  paidDate: p.paid_date || "",
  paidAmount: p.paid_amount,
  method: p.method || "",
  invoiceNo: p.invoice_no || "",
  receiptNo: p.receipt_no || "",
  discount: p.discount || 0,
  slipKey: p.slip_key || "",
});
const mapAdhocBill = (b, items) => ({
  id: b.id,
  caseId: b.case_id,
  billDate: b.bill_date || "",
  note: b.note || "",
  discount: b.discount || 0,
  paid: !!b.paid,
  paidDate: b.paid_date || "",
  paidAmount: b.paid_amount,
  method: b.method || "",
  invoiceNo: b.invoice_no || "",
  receiptNo: b.receipt_no || "",
  slipKey: b.slip_key || "",
  items: (items || []).map((it) => ({ id: it.id, desc: it.desc, amount: it.amount, category: it.category || "" })),
});
const mapAppointment = (a) => ({
  id: a.id,
  caseId: a.case_id,
  date: a.date || "",
  note: a.note || "",
  status: a.status || "scheduled",
});

/* ================= FULL STATE (admin) ================= */

async function loadState(db) {
  const orgs = (await db.prepare("SELECT * FROM orgs").all()).results.map(mapOrg);
  const branches = (await db.prepare("SELECT * FROM branches").all()).results.map(mapBranch);
  const bankAccounts = (await db.prepare("SELECT * FROM bank_accounts").all()).results.map(mapBankAccount);
  const cases = (await db.prepare("SELECT * FROM cases").all()).results.map(mapCase);

  const entries = {};
  for (const e of (await db.prepare("SELECT * FROM entries").all()).results) {
    const k = `${e.case_id}|${e.ym}`;
    (entries[k] ||= []).push({ id: e.id, date: e.date || "", desc: e.desc, amount: e.amount, category: e.category || "" });
  }
  const payments = {};
  for (const p of (await db.prepare("SELECT * FROM payments").all()).results) {
    payments[`${p.case_id}|${p.ym}`] = mapPayment(p);
  }
  const feeToggles = {};
  for (const f of (await db.prepare("SELECT * FROM fee_toggles").all()).results) {
    feeToggles[`${f.case_id}|${f.ym}`] = !!f.included;
  }

  const adhocItemsByBill = {};
  for (const it of (await db.prepare("SELECT * FROM adhoc_bill_items").all()).results) {
    (adhocItemsByBill[it.bill_id] ||= []).push(it);
  }
  const adhocBills = (await db.prepare("SELECT * FROM adhoc_bills").all()).results.map((b) => mapAdhocBill(b, adhocItemsByBill[b.id]));

  const appointments = (await db.prepare("SELECT * FROM appointments").all()).results.map(mapAppointment);

  return { orgs, branches, bankAccounts, cases, entries, payments, feeToggles, adhocBills, appointments };
}

async function saveState(db, state) {
  const stmts = [
    db.prepare("DELETE FROM adhoc_bill_items"),
    db.prepare("DELETE FROM adhoc_bills"),
    db.prepare("DELETE FROM appointments"),
    db.prepare("DELETE FROM fee_toggles"),
    db.prepare("DELETE FROM payments"),
    db.prepare("DELETE FROM entries"),
    db.prepare("DELETE FROM cases"),
    db.prepare("DELETE FROM bank_accounts"),
    db.prepare("DELETE FROM branches"),
    db.prepare("DELETE FROM orgs"),
  ];

  for (const o of state.orgs || []) {
    stmts.push(db.prepare("INSERT INTO orgs (id,name,tax_id,address,phone,staff) VALUES (?,?,?,?,?,?)").bind(o.id, o.name || "", o.taxId || "", o.address || "", o.phone || "", o.staff || ""));
  }
  for (const b of state.branches || []) {
    stmts.push(db.prepare("INSERT INTO branches (id,org_id,name,address,phone,code,staff,signature_key,logo,logo_key,note) VALUES (?,?,?,?,?,?,?,?,?,?,?)").bind(b.id, b.orgId, b.name || "", b.address || "", b.phone || "", b.code || "", b.staff || "", b.signatureKey || "", b.logo || "", b.logoKey || "", b.note || ""));
  }
  for (const a of state.bankAccounts || []) {
    stmts.push(
      db
        .prepare("INSERT INTO bank_accounts (id,branch_id,bank_name,bank_acc,bank_owner,doc_numbering,withholding_tax) VALUES (?,?,?,?,?,?,?)")
        .bind(a.id, a.branchId, a.bankName || "", a.bankAcc || "", a.bankOwner || "", a.docNumbering || "shared", a.withholdingTax || "none")
    );
  }
  for (const c of state.cases || []) {
    stmts.push(
      db
        .prepare(
          `INSERT INTO cases (id,branch_id,name,note,monthly_fee,due_day,bank_name,bank_acc,bank_owner,bank_account_id,age,health_info,allergy,emergency_contact,emergency_phone,admission_date,due_date_override,withholding_override,address,phone,tax_id,photo_key,moved_out,move_out_date)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`
        )
        .bind(
          c.id, c.branchId || null, c.name, c.note || "", c.monthlyFee || 0, c.dueDay || 1, c.bankName || "", c.bankAcc || "", c.bankOwner || "", c.bankAccountId || null,
          c.age ?? null, c.healthInfo || "", c.allergy || "", c.emergencyContact || "", c.emergencyPhone || "", c.admissionDate || "", c.dueDateOverride || "",
          c.withholdingOverride || "", c.address || "", c.phone || "", c.taxId || "", c.photoKey || "",
          c.movedOut ? 1 : 0, c.moveOutDate || null
        )
    );
  }
  for (const k of Object.keys(state.entries || {})) {
    const [caseId, ym] = k.split("|");
    for (const it of state.entries[k]) {
      stmts.push(db.prepare("INSERT INTO entries (id,case_id,ym,date,desc,amount,category) VALUES (?,?,?,?,?,?,?)").bind(it.id, caseId, ym, it.date || "", it.desc, it.amount || 0, it.category || ""));
    }
  }
  for (const k of Object.keys(state.payments || {})) {
    const [caseId, ym] = k.split("|");
    const p = state.payments[k];
    stmts.push(
      db
        .prepare(`INSERT INTO payments (case_id,ym,paid,paid_date,paid_amount,method,invoice_no,receipt_no,discount,slip_key) VALUES (?,?,?,?,?,?,?,?,?,?)`)
        .bind(caseId, ym, p.paid ? 1 : 0, p.paidDate || null, p.paidAmount ?? null, p.method || "", p.invoiceNo || "", p.receiptNo || "", p.discount || 0, p.slipKey || "")
    );
  }
  for (const k of Object.keys(state.feeToggles || {})) {
    const [caseId, ym] = k.split("|");
    stmts.push(db.prepare("INSERT INTO fee_toggles (case_id,ym,included) VALUES (?,?,?)").bind(caseId, ym, state.feeToggles[k] ? 1 : 0));
  }
  for (const b of state.adhocBills || []) {
    stmts.push(
      db
        .prepare(
          `INSERT INTO adhoc_bills (id,case_id,bill_date,note,discount,paid,paid_date,paid_amount,method,invoice_no,receipt_no,slip_key)
           VALUES (?,?,?,?,?,?,?,?,?,?,?,?)`
        )
        .bind(
          b.id, b.caseId, b.billDate || "", b.note || "", b.discount || 0, b.paid ? 1 : 0,
          b.paidDate || null, b.paidAmount ?? null, b.method || "", b.invoiceNo || "", b.receiptNo || "", b.slipKey || ""
        )
    );
    for (const it of b.items || []) {
      stmts.push(db.prepare("INSERT INTO adhoc_bill_items (id,bill_id,desc,amount,category) VALUES (?,?,?,?,?)").bind(it.id, b.id, it.desc, it.amount || 0, it.category || ""));
    }
  }
  for (const a of state.appointments || []) {
    stmts.push(
      db
        .prepare("INSERT INTO appointments (id,case_id,date,note,status) VALUES (?,?,?,?,?)")
        .bind(a.id, a.caseId, a.date || "", a.note || "", a.status || "scheduled")
    );
  }
  await db.batch(stmts);
}

/* ================= SCOPED STATE (staff เฉพาะสาขาตัวเอง / manager หลายสาขาตามที่ admin อนุญาต) ================= */

async function loadScopedState(db, branchIds) {
  if (!branchIds || !branchIds.length) {
    return { orgs: [], branches: [], bankAccounts: [], cases: [], entries: {}, payments: {}, feeToggles: {}, adhocBills: [], appointments: [] };
  }

  const branchPlaceholders = branchIds.map(() => "?").join(",");
  const branchesRes = await db.prepare(`SELECT * FROM branches WHERE id IN (${branchPlaceholders})`).bind(...branchIds).all();
  const branches = branchesRes.results.map(mapBranch);
  const orgIds = [...new Set(branches.map((b) => b.orgId).filter(Boolean))];
  const orgs = orgIds.length
    ? (await db.prepare(`SELECT * FROM orgs WHERE id IN (${orgIds.map(() => "?").join(",")})`).bind(...orgIds).all()).results.map(mapOrg)
    : [];
  const bankAccountsRes = await db.prepare(`SELECT * FROM bank_accounts WHERE branch_id IN (${branchPlaceholders})`).bind(...branchIds).all();
  const casesRes = await db.prepare(`SELECT * FROM cases WHERE branch_id IN (${branchPlaceholders})`).bind(...branchIds).all();
  const cases = casesRes.results.map(mapCase);
  const caseIds = cases.map((c) => c.id);

  const entries = {};
  const payments = {};
  const feeToggles = {};
  if (caseIds.length) {
    const placeholders = caseIds.map(() => "?").join(",");
    const entriesRes = await db.prepare(`SELECT * FROM entries WHERE case_id IN (${placeholders})`).bind(...caseIds).all();
    for (const e of entriesRes.results) {
      const k = `${e.case_id}|${e.ym}`;
      (entries[k] ||= []).push({ id: e.id, date: e.date || "", desc: e.desc, amount: e.amount, category: e.category || "" });
    }
    const paymentsRes = await db.prepare(`SELECT * FROM payments WHERE case_id IN (${placeholders})`).bind(...caseIds).all();
    for (const p of paymentsRes.results) payments[`${p.case_id}|${p.ym}`] = mapPayment(p);
    const feeTogglesRes = await db.prepare(`SELECT * FROM fee_toggles WHERE case_id IN (${placeholders})`).bind(...caseIds).all();
    for (const f of feeTogglesRes.results) feeToggles[`${f.case_id}|${f.ym}`] = !!f.included;
  }

  let adhocBills = [];
  if (caseIds.length) {
    const placeholders = caseIds.map(() => "?").join(",");
    const billsRes = await db.prepare(`SELECT * FROM adhoc_bills WHERE case_id IN (${placeholders})`).bind(...caseIds).all();
    const billIds = billsRes.results.map((b) => b.id);
    const itemsByBill = {};
    if (billIds.length) {
      const itemPlaceholders = billIds.map(() => "?").join(",");
      const itemsRes = await db.prepare(`SELECT * FROM adhoc_bill_items WHERE bill_id IN (${itemPlaceholders})`).bind(...billIds).all();
      for (const it of itemsRes.results) (itemsByBill[it.bill_id] ||= []).push(it);
    }
    adhocBills = billsRes.results.map((b) => mapAdhocBill(b, itemsByBill[b.id]));
  }

  let appointments = [];
  if (caseIds.length) {
    const placeholders = caseIds.map(() => "?").join(",");
    const appointmentsRes = await db.prepare(`SELECT * FROM appointments WHERE case_id IN (${placeholders})`).bind(...caseIds).all();
    appointments = appointmentsRes.results.map(mapAppointment);
  }

  return { orgs, branches, bankAccounts: bankAccountsRes.results.map(mapBankAccount), cases, entries, payments, feeToggles, adhocBills, appointments };
}

// staff/manager บันทึกได้เฉพาะเคส/รายการ/การชำระเงิน ที่อยู่ในสาขาที่ตนเข้าถึงได้เท่านั้น
// จะไม่แตะตาราง orgs/branches/bank_accounts และจะไม่ลบ/แก้ข้อมูลของสาขาอื่นโดยเด็ดขาด
async function saveScopedState(db, state, branchIds) {
  if (!branchIds || !branchIds.length) throw new Error("บัญชีนี้ยังไม่มีสิทธิ์เข้าถึงสาขาใดเลย ไม่สามารถบันทึกข้อมูลได้ — กรุณาติดต่อผู้ดูแลระบบ");

  const scopedCases = (state.cases || []).filter((c) => branchIds.includes(c.branchId || ""));
  const scopedCaseIds = scopedCases.map((c) => c.id);

  const branchPlaceholders = branchIds.map(() => "?").join(",");
  const existingIds = (await db.prepare(`SELECT id FROM cases WHERE branch_id IN (${branchPlaceholders})`).bind(...branchIds).all()).results.map(
    (r) => r.id
  );

  const stmts = [];

  // ลบเคส (และรายการ/การชำระเงินของเคสนั้น) ที่เคยมีในสาขานี้แต่ไม่มีในชุดข้อมูลที่ส่งมาแล้ว
  for (const id of existingIds) {
    if (!scopedCaseIds.includes(id)) {
      stmts.push(db.prepare("DELETE FROM entries WHERE case_id = ?").bind(id));
      stmts.push(db.prepare("DELETE FROM payments WHERE case_id = ?").bind(id));
      stmts.push(db.prepare("DELETE FROM fee_toggles WHERE case_id = ?").bind(id));
      stmts.push(db.prepare("DELETE FROM adhoc_bill_items WHERE bill_id IN (SELECT id FROM adhoc_bills WHERE case_id = ?)").bind(id));
      stmts.push(db.prepare("DELETE FROM adhoc_bills WHERE case_id = ?").bind(id));
      stmts.push(db.prepare("DELETE FROM appointments WHERE case_id = ?").bind(id));
      stmts.push(db.prepare("DELETE FROM cases WHERE id = ?").bind(id));
    }
  }

  // เพิ่ม/แก้ไขเคสในสาขาที่ตนเข้าถึงได้ (บังคับ branch_id ให้เป็นหนึ่งในสาขาที่ตนเข้าถึงได้เสมอ ป้องกันการสวมสิทธิ์ข้ามสาขา — กรองไว้แล้วใน scopedCases)
  for (const c of scopedCases) {
    stmts.push(
      db.prepare(`
        INSERT INTO cases (id,branch_id,name,note,monthly_fee,due_day,bank_name,bank_acc,bank_owner,bank_account_id,age,health_info,allergy,emergency_contact,emergency_phone,admission_date,due_date_override,withholding_override,address,phone,tax_id,photo_key,moved_out,move_out_date)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        ON CONFLICT(id) DO UPDATE SET
          branch_id=excluded.branch_id, name=excluded.name, note=excluded.note,
          monthly_fee=excluded.monthly_fee, due_day=excluded.due_day,
          bank_name=excluded.bank_name, bank_acc=excluded.bank_acc, bank_owner=excluded.bank_owner, bank_account_id=excluded.bank_account_id,
          age=excluded.age, health_info=excluded.health_info, allergy=excluded.allergy,
          emergency_contact=excluded.emergency_contact, emergency_phone=excluded.emergency_phone,
          admission_date=excluded.admission_date, due_date_override=excluded.due_date_override,
          withholding_override=excluded.withholding_override, address=excluded.address, phone=excluded.phone, tax_id=excluded.tax_id, photo_key=excluded.photo_key,
          moved_out=excluded.moved_out, move_out_date=excluded.move_out_date
      `).bind(
        c.id, c.branchId, c.name, c.note || "", c.monthlyFee || 0, c.dueDay || 1, c.bankName || "", c.bankAcc || "", c.bankOwner || "", c.bankAccountId || null,
        c.age ?? null, c.healthInfo || "", c.allergy || "", c.emergencyContact || "", c.emergencyPhone || "", c.admissionDate || "", c.dueDateOverride || "",
        c.withholdingOverride || "", c.address || "", c.phone || "", c.taxId || "", c.photoKey || "",
        c.movedOut ? 1 : 0, c.moveOutDate || null
      )
    );
  }

  // แทนที่รายการค่าใช้จ่ายทั้งหมดของเคสในสาขาตัวเอง
  for (const id of scopedCaseIds) {
    stmts.push(db.prepare("DELETE FROM entries WHERE case_id = ?").bind(id));
  }
  for (const k of Object.keys(state.entries || {})) {
    const [caseId, ym] = k.split("|");
    if (!scopedCaseIds.includes(caseId)) continue; // ข้ามรายการที่ไม่ใช่ของสาขาตัวเอง
    for (const it of state.entries[k]) {
      stmts.push(db.prepare("INSERT INTO entries (id,case_id,ym,date,desc,amount,category) VALUES (?,?,?,?,?,?,?)").bind(it.id, caseId, ym, it.date || "", it.desc, it.amount || 0, it.category || ""));
    }
  }

  // อัปเดตการชำระเงินของเคสในสาขาตัวเอง
  for (const k of Object.keys(state.payments || {})) {
    const [caseId, ym] = k.split("|");
    if (!scopedCaseIds.includes(caseId)) continue;
    const p = state.payments[k];
    stmts.push(
      db.prepare(`
        INSERT INTO payments (case_id,ym,paid,paid_date,paid_amount,method,invoice_no,receipt_no,discount,slip_key)
        VALUES (?,?,?,?,?,?,?,?,?,?)
        ON CONFLICT(case_id,ym) DO UPDATE SET
          paid=excluded.paid, paid_date=excluded.paid_date, paid_amount=excluded.paid_amount,
          method=excluded.method, invoice_no=excluded.invoice_no, receipt_no=excluded.receipt_no,
          discount=excluded.discount, slip_key=excluded.slip_key
      `).bind(caseId, ym, p.paid ? 1 : 0, p.paidDate || null, p.paidAmount ?? null, p.method || "", p.invoiceNo || "", p.receiptNo || "", p.discount || 0, p.slipKey || "")
    );
  }

  // อัปเดตการเปิด/ปิดค่าบริการประจำเดือนของเคสในสาขาตัวเอง
  for (const k of Object.keys(state.feeToggles || {})) {
    const [caseId, ym] = k.split("|");
    if (!scopedCaseIds.includes(caseId)) continue;
    stmts.push(
      db.prepare(`
        INSERT INTO fee_toggles (case_id,ym,included) VALUES (?,?,?)
        ON CONFLICT(case_id,ym) DO UPDATE SET included=excluded.included
      `).bind(caseId, ym, state.feeToggles[k] ? 1 : 0)
    );
  }

  // บิลพิเศษระหว่างเดือน — แทนที่ทั้งหมดเฉพาะของเคสในสาขาตัวเอง (ไม่แตะบิลของสาขาอื่น)
  const scopedAdhocBills = (state.adhocBills || []).filter((b) => scopedCaseIds.includes(b.caseId));
  const scopedAdhocBillIds = scopedAdhocBills.map((b) => b.id);
  const existingAdhocIds = scopedCaseIds.length
    ? (
        await db
          .prepare(`SELECT id FROM adhoc_bills WHERE case_id IN (${scopedCaseIds.map(() => "?").join(",")})`)
          .bind(...scopedCaseIds)
          .all()
      ).results.map((r) => r.id)
    : [];
  for (const id of existingAdhocIds) {
    if (!scopedAdhocBillIds.includes(id)) {
      stmts.push(db.prepare("DELETE FROM adhoc_bill_items WHERE bill_id = ?").bind(id));
      stmts.push(db.prepare("DELETE FROM adhoc_bills WHERE id = ?").bind(id));
    }
  }
  for (const b of scopedAdhocBills) {
    stmts.push(
      db.prepare(`
        INSERT INTO adhoc_bills (id,case_id,bill_date,note,discount,paid,paid_date,paid_amount,method,invoice_no,receipt_no,slip_key)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
        ON CONFLICT(id) DO UPDATE SET
          case_id=excluded.case_id, bill_date=excluded.bill_date, note=excluded.note, discount=excluded.discount,
          paid=excluded.paid, paid_date=excluded.paid_date, paid_amount=excluded.paid_amount,
          method=excluded.method, invoice_no=excluded.invoice_no, receipt_no=excluded.receipt_no, slip_key=excluded.slip_key
      `).bind(
        b.id, b.caseId, b.billDate || "", b.note || "", b.discount || 0, b.paid ? 1 : 0,
        b.paidDate || null, b.paidAmount ?? null, b.method || "", b.invoiceNo || "", b.receiptNo || "", b.slipKey || ""
      )
    );
    stmts.push(db.prepare("DELETE FROM adhoc_bill_items WHERE bill_id = ?").bind(b.id));
    for (const it of b.items || []) {
      stmts.push(db.prepare("INSERT INTO adhoc_bill_items (id,bill_id,desc,amount,category) VALUES (?,?,?,?,?)").bind(it.id, b.id, it.desc, it.amount || 0, it.category || ""));
    }
  }

  // นัดหมอ — แทนที่ทั้งหมดเฉพาะของเคสในสาขาตัวเอง
  for (const id of scopedCaseIds) {
    stmts.push(db.prepare("DELETE FROM appointments WHERE case_id = ?").bind(id));
  }
  for (const a of state.appointments || []) {
    if (!scopedCaseIds.includes(a.caseId)) continue;
    stmts.push(
      db.prepare("INSERT INTO appointments (id,case_id,date,note,status) VALUES (?,?,?,?,?)").bind(a.id, a.caseId, a.date || "", a.note || "", a.status || "scheduled")
    );
  }

  if (stmts.length) await db.batch(stmts);
}
