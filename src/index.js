/**
 * ระบบบันทึกค่าใช้จ่ายผู้สูงอายุ — Cloudflare Worker API (มีระบบ login + สิทธิ์ตามสาขา)
 *
 * Endpoints:
 *   POST /api/login    { username, password } -> ตั้ง session cookie
 *   POST /api/logout   -> ล้าง session cookie
 *   GET  /api/me       -> ข้อมูลผู้ใช้ปัจจุบัน
 *   GET  /api/state    -> โหลดข้อมูล (admin เห็นทั้งหมด, staff เห็นเฉพาะสาขาตัวเอง)
 *   POST /api/state    -> บันทึกข้อมูล (admin บันทึกได้ทั้งหมด, staff บันทึกได้เฉพาะสาขาตัวเอง)
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
          const state = user.role === "admin" ? await loadState(env.DB) : await loadScopedState(env.DB, user);
          return json(state);
        }
        if (request.method === "POST") {
          const body = await request.json();
          if (user.role === "admin") {
            await saveState(env.DB, body);
          } else {
            await saveScopedState(env.DB, body, user);
          }
          return json({ ok: true });
        }
      }

      if (url.pathname === "/api/users" || url.pathname.startsWith("/api/users/")) {
        const user = await getUser(request, env);
        if (!user) return json({ error: "unauthorized" }, 401);
        if (user.role !== "admin") return json({ error: "forbidden — เฉพาะผู้ดูแลระบบเท่านั้น" }, 403);
        return await handleUsers(request, env, url, user);
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

  // GET /api/users — รายชื่อผู้ใช้ทั้งหมด (ไม่ส่ง password_hash/salt กลับ)
  if (parts.length === 2 && request.method === "GET") {
    const rows = (await env.DB.prepare("SELECT id,username,display_name,role,org_id,branch_id FROM users ORDER BY username").all()).results;
    return json({ users: rows.map(mapUserRow) });
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

  return json({ error: "not found" }, 404);
}

function mapUserRow(r) {
  return {
    id: r.id,
    username: r.username,
    displayName: r.display_name || "",
    role: r.role,
    orgId: r.org_id || "",
    branchId: r.branch_id || "",
  };
}

async function createUser(request, env) {
  const body = await request.json().catch(() => ({}));
  const { username, password, displayName, role, orgId, branchId } = body;

  if (!username || !password || !displayName || !role) return json({ error: "กรุณากรอกข้อมูลให้ครบ" }, 400);
  if (role !== "admin" && role !== "staff") return json({ error: "role ต้องเป็น admin หรือ staff เท่านั้น" }, 400);
  if (password.length < 6) return json({ error: "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร" }, 400);
  if (role === "staff" && (!orgId || !branchId)) return json({ error: "ผู้ใช้ role staff ต้องเลือกองค์กรและสาขา" }, 400);

  const usernameTaken = await env.DB.prepare("SELECT id FROM users WHERE username = ?").bind(username).first();
  if (usernameTaken) return json({ error: "ชื่อผู้ใช้นี้ถูกใช้แล้ว" }, 400);

  if (role === "staff") {
    const branchRow = await env.DB.prepare("SELECT id FROM branches WHERE id = ? AND org_id = ?").bind(branchId, orgId).first();
    if (!branchRow) return json({ error: "ไม่พบสาขาที่เลือก หรือสาขาไม่ได้สังกัดองค์กรที่เลือก" }, 400);
  }

  const id = "user_" + generateHex(8);
  const salt = generateSaltHex();
  const hash = await hashPassword(password, salt);

  await env.DB.prepare(
    "INSERT INTO users (id, username, password_hash, salt, display_name, role, org_id, branch_id) VALUES (?,?,?,?,?,?,?,?)"
  ).bind(id, username, hash, salt, displayName, role, role === "staff" ? orgId : null, role === "staff" ? branchId : null).run();

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

const mapOrg = (o) => ({ id: o.id, name: o.name, logo: o.logo || "", staff: o.staff || "", note: o.note || "" });
const mapBranch = (b) => ({ id: b.id, orgId: b.org_id, name: b.name, address: b.address || "", phone: b.phone || "" });
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
});
const mapPayment = (p) => ({
  paid: !!p.paid,
  paidDate: p.paid_date || "",
  paidAmount: p.paid_amount,
  method: p.method || "",
  invoiceNo: p.invoice_no || "",
  receiptNo: p.receipt_no || "",
});

/* ================= FULL STATE (admin) ================= */

async function loadState(db) {
  const orgs = (await db.prepare("SELECT * FROM orgs").all()).results.map(mapOrg);
  const branches = (await db.prepare("SELECT * FROM branches").all()).results.map(mapBranch);
  const cases = (await db.prepare("SELECT * FROM cases").all()).results.map(mapCase);

  const entries = {};
  for (const e of (await db.prepare("SELECT * FROM entries").all()).results) {
    const k = `${e.case_id}|${e.ym}`;
    (entries[k] ||= []).push({ id: e.id, date: e.date || "", desc: e.desc, amount: e.amount });
  }
  const payments = {};
  for (const p of (await db.prepare("SELECT * FROM payments").all()).results) {
    payments[`${p.case_id}|${p.ym}`] = mapPayment(p);
  }
  return { orgs, branches, cases, entries, payments };
}

async function saveState(db, state) {
  const stmts = [
    db.prepare("DELETE FROM payments"),
    db.prepare("DELETE FROM entries"),
    db.prepare("DELETE FROM cases"),
    db.prepare("DELETE FROM branches"),
    db.prepare("DELETE FROM orgs"),
  ];

  for (const o of state.orgs || []) {
    stmts.push(db.prepare("INSERT INTO orgs (id,name,logo,staff,note) VALUES (?,?,?,?,?)").bind(o.id, o.name || "", o.logo || "", o.staff || "", o.note || ""));
  }
  for (const b of state.branches || []) {
    stmts.push(db.prepare("INSERT INTO branches (id,org_id,name,address,phone) VALUES (?,?,?,?,?)").bind(b.id, b.orgId, b.name || "", b.address || "", b.phone || ""));
  }
  for (const c of state.cases || []) {
    stmts.push(
      db
        .prepare(`INSERT INTO cases (id,branch_id,name,note,monthly_fee,due_day,bank_name,bank_acc,bank_owner) VALUES (?,?,?,?,?,?,?,?,?)`)
        .bind(c.id, c.branchId || null, c.name, c.note || "", c.monthlyFee || 0, c.dueDay || 1, c.bankName || "", c.bankAcc || "", c.bankOwner || "")
    );
  }
  for (const k of Object.keys(state.entries || {})) {
    const [caseId, ym] = k.split("|");
    for (const it of state.entries[k]) {
      stmts.push(db.prepare("INSERT INTO entries (id,case_id,ym,date,desc,amount) VALUES (?,?,?,?,?,?)").bind(it.id, caseId, ym, it.date || "", it.desc, it.amount || 0));
    }
  }
  for (const k of Object.keys(state.payments || {})) {
    const [caseId, ym] = k.split("|");
    const p = state.payments[k];
    stmts.push(
      db
        .prepare(`INSERT INTO payments (case_id,ym,paid,paid_date,paid_amount,method,invoice_no,receipt_no) VALUES (?,?,?,?,?,?,?,?)`)
        .bind(caseId, ym, p.paid ? 1 : 0, p.paidDate || null, p.paidAmount ?? null, p.method || "", p.invoiceNo || "", p.receiptNo || "")
    );
  }
  await db.batch(stmts);
}

/* ================= SCOPED STATE (staff — เฉพาะสาขาตัวเอง) ================= */

async function loadScopedState(db, user) {
  if (!user.branchId) return { orgs: [], branches: [], cases: [], entries: {}, payments: {} };

  const branchRow = await db.prepare("SELECT * FROM branches WHERE id = ?").bind(user.branchId).first();
  const orgRow = user.orgId ? await db.prepare("SELECT * FROM orgs WHERE id = ?").bind(user.orgId).first() : null;
  const casesRes = await db.prepare("SELECT * FROM cases WHERE branch_id = ?").bind(user.branchId).all();
  const cases = casesRes.results.map(mapCase);
  const caseIds = cases.map((c) => c.id);

  const entries = {};
  const payments = {};
  if (caseIds.length) {
    const placeholders = caseIds.map(() => "?").join(",");
    const entriesRes = await db.prepare(`SELECT * FROM entries WHERE case_id IN (${placeholders})`).bind(...caseIds).all();
    for (const e of entriesRes.results) {
      const k = `${e.case_id}|${e.ym}`;
      (entries[k] ||= []).push({ id: e.id, date: e.date || "", desc: e.desc, amount: e.amount });
    }
    const paymentsRes = await db.prepare(`SELECT * FROM payments WHERE case_id IN (${placeholders})`).bind(...caseIds).all();
    for (const p of paymentsRes.results) payments[`${p.case_id}|${p.ym}`] = mapPayment(p);
  }

  return {
    orgs: orgRow ? [mapOrg(orgRow)] : [],
    branches: branchRow ? [mapBranch(branchRow)] : [],
    cases,
    entries,
    payments,
  };
}

// staff บันทึกได้เฉพาะเคส/รายการ/การชำระเงิน ที่อยู่ในสาขาของตัวเองเท่านั้น
// จะไม่แตะตาราง orgs/branches และจะไม่ลบ/แก้ข้อมูลของสาขาอื่นโดยเด็ดขาด
async function saveScopedState(db, state, user) {
  if (!user.branchId) throw new Error("บัญชีนี้ยังไม่ได้ผูกกับสาขา ไม่สามารถบันทึกข้อมูลได้ — กรุณาติดต่อผู้ดูแลระบบ");
  const branchId = user.branchId;

  const scopedCases = (state.cases || []).filter((c) => (c.branchId || "") === branchId);
  const scopedCaseIds = scopedCases.map((c) => c.id);

  const existingIds = (await db.prepare("SELECT id FROM cases WHERE branch_id = ?").bind(branchId).all()).results.map((r) => r.id);

  const stmts = [];

  // ลบเคส (และรายการ/การชำระเงินของเคสนั้น) ที่เคยมีในสาขานี้แต่ไม่มีในชุดข้อมูลที่ส่งมาแล้ว
  for (const id of existingIds) {
    if (!scopedCaseIds.includes(id)) {
      stmts.push(db.prepare("DELETE FROM entries WHERE case_id = ?").bind(id));
      stmts.push(db.prepare("DELETE FROM payments WHERE case_id = ?").bind(id));
      stmts.push(db.prepare("DELETE FROM cases WHERE id = ?").bind(id));
    }
  }

  // เพิ่ม/แก้ไขเคสของสาขาตัวเอง (บังคับ branch_id เป็นสาขาของผู้ใช้เสมอ ป้องกันการสวมสิทธิ์ข้ามสาขา)
  for (const c of scopedCases) {
    stmts.push(
      db.prepare(`
        INSERT INTO cases (id,branch_id,name,note,monthly_fee,due_day,bank_name,bank_acc,bank_owner)
        VALUES (?,?,?,?,?,?,?,?,?)
        ON CONFLICT(id) DO UPDATE SET
          branch_id=excluded.branch_id, name=excluded.name, note=excluded.note,
          monthly_fee=excluded.monthly_fee, due_day=excluded.due_day,
          bank_name=excluded.bank_name, bank_acc=excluded.bank_acc, bank_owner=excluded.bank_owner
      `).bind(c.id, branchId, c.name, c.note || "", c.monthlyFee || 0, c.dueDay || 1, c.bankName || "", c.bankAcc || "", c.bankOwner || "")
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
      stmts.push(db.prepare("INSERT INTO entries (id,case_id,ym,date,desc,amount) VALUES (?,?,?,?,?,?)").bind(it.id, caseId, ym, it.date || "", it.desc, it.amount || 0));
    }
  }

  // อัปเดตการชำระเงินของเคสในสาขาตัวเอง
  for (const k of Object.keys(state.payments || {})) {
    const [caseId, ym] = k.split("|");
    if (!scopedCaseIds.includes(caseId)) continue;
    const p = state.payments[k];
    stmts.push(
      db.prepare(`
        INSERT INTO payments (case_id,ym,paid,paid_date,paid_amount,method,invoice_no,receipt_no)
        VALUES (?,?,?,?,?,?,?,?)
        ON CONFLICT(case_id,ym) DO UPDATE SET
          paid=excluded.paid, paid_date=excluded.paid_date, paid_amount=excluded.paid_amount,
          method=excluded.method, invoice_no=excluded.invoice_no, receipt_no=excluded.receipt_no
      `).bind(caseId, ym, p.paid ? 1 : 0, p.paidDate || null, p.paidAmount ?? null, p.method || "", p.invoiceNo || "", p.receiptNo || "")
    );
  }

  if (stmts.length) await db.batch(stmts);
}
