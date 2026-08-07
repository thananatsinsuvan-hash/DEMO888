PRAGMA defer_foreign_keys=TRUE;
CREATE TABLE orgs (
  id    TEXT PRIMARY KEY,
  name  TEXT NOT NULL,
  logo  TEXT,
  staff TEXT,
  note  TEXT
, logo_key TEXT, company_name TEXT NOT NULL DEFAULT '', tax_id TEXT NOT NULL DEFAULT '', address TEXT NOT NULL DEFAULT '', phone TEXT NOT NULL DEFAULT '');
INSERT INTO "orgs" ("id","name","logo","staff","note","logo_key","company_name","tax_id","address","phone") VALUES('mrm0mwlsmit8z','บริษัท 2 อันดาเวลเนส จำกัด',NULL,'',NULL,NULL,'','0105568175186','768/93 ซอยพัฒนาการ38 ถนนพัฒนาการ แขวงสวนหลวง เขตสวนหลวง กรุงเทพมหานคร','065-417-9444');
INSERT INTO "orgs" ("id","name","logo","staff","note","logo_key","company_name","tax_id","address","phone") VALUES('mrm1tvnrhvvh6','ศูนย์ดูแลผู้สูงอายุ มาสุเนอร์สซิ่งโฮม',NULL,'',NULL,NULL,'','','','');
INSERT INTO "orgs" ("id","name","logo","staff","note","logo_key","company_name","tax_id","address","phone") VALUES('mrx92t05tzli1','จามจุรี',NULL,'',NULL,NULL,'','','','');
INSERT INTO "orgs" ("id","name","logo","staff","note","logo_key","company_name","tax_id","address","phone") VALUES('mrxnn6r8wlrh8','บริษัททดสอบ',NULL,'',NULL,NULL,'','1234567891011','123 ซอย1 ถนนหลังสวน แขวงจุดๆๆ เขตจุดๆๆ กรุงเทพมหานคร','02-021-2211');
CREATE TABLE branches (
  id      TEXT PRIMARY KEY,
  org_id  TEXT NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  name    TEXT NOT NULL,
  address TEXT,
  phone   TEXT
, code TEXT, staff TEXT DEFAULT '', signature_key TEXT DEFAULT '', logo TEXT NOT NULL DEFAULT '', logo_key TEXT NOT NULL DEFAULT '', note TEXT NOT NULL DEFAULT '');
INSERT INTO "branches" ("id","org_id","name","address","phone","code","staff","signature_key","logo","logo_key","note") VALUES('mrm0nhoxgn7rg','mrm0mwlsmit8z','ศูนย์ดูแลผู้สูงอายุ มาสุเนอร์สซิ่งโฮม งามวงศ์วาน','173/1 ซ.งามวงศ์วาน 30 ถ.งามวงศ์วาน ทุ่งสองห้อง หลักสี่ กรุงเทพฯ 10210','091-299-1644 , 065-417-9444','M02','เมย์','','MASU','org-mrm0mwlsmit8z-1784189982439.jpeg','');
INSERT INTO "branches" ("id","org_id","name","address","phone","code","staff","signature_key","logo","logo_key","note") VALUES('mrm1sbqy8v3zb','mrm1tvnrhvvh6','ศูนย์ดูแลผู้สูงอายุ มาสุเนอร์สซิ่งโฮม ประชาชื่น','72 ซ.งามวงศ์วาน 31 แยก 16 ถ.งามวงศ์วาน ต.บางเขน อ.เมืองนนทบุรี จ.นนทบุรี 11000','091-299-1644 , 093-564-4742','M01','นางสาวเอ','','MASU','org-mrm0mwlsmit8z-1784189982439.jpeg','');
INSERT INTO "branches" ("id","org_id","name","address","phone","code","staff","signature_key","logo","logo_key","note") VALUES('mrm1vq2rwh9kf','mrx92t05tzli1','ศูนย์ดูแลผู้สูงอายุ จามจุรีเนอร์สซิ่งโฮม รัชโยธิน','456 ซ.พหลโยธิน 35 แยก 5-2-3 ลาดยาว จตุจักร กรุงเทพฯ 10900','091-599-6662','J01','','','จามจุรี','','หากชำระเงินสด มีส่วนลด 300 บาท');
INSERT INTO "branches" ("id","org_id","name","address","phone","code","staff","signature_key","logo","logo_key","note") VALUES('mrn732ey93cog','mrx92t05tzli1','ศูนย์ดูแลผู้สูงอายุ จามจุรีเนอร์สซิ่งโฮม ลาดพร้าว 38','888 ซ.ลาดพร้าว 38 ถ.ลาดพร้าว ........','099-999-9911','J02','','','จามจุรี','','หากชำระเงินสด มีส่วนลด 300 บาท');
INSERT INTO "branches" ("id","org_id","name","address","phone","code","staff","signature_key","logo","logo_key","note") VALUES('mrn74e5733z9c','mrm0mwlsmit8z','ศูนย์ดูแลผู้สูงอายุ จามจุรีเนอร์สซิ่งโฮม บางเขน','88 ซ.พหลโยธิน 63 ถ.พหลโยธิน อนุสาวรีย์ บางเขน กรุงเทพฯ','091-191-9111','J03','','','จามจุรี','','หากชำระเงินสด มีส่วนลด 300 บาท');
INSERT INTO "branches" ("id","org_id","name","address","phone","code","staff","signature_key","logo","logo_key","note") VALUES('mrxntglf98zew','mrxnn6r8wlrh8','ศูนยดูแลผู้สูงอายุทดสอบ','456 …………………………………………………','098-765-4321','T01','น.ส.เอ นามสมมติ','','Test','','หากชำระเงินสดมีส่วนลดค่าบริการรายเดือน 300 บาท');
CREATE TABLE cases (
  id           TEXT PRIMARY KEY,
  branch_id    TEXT REFERENCES branches(id) ON DELETE SET NULL,
  name         TEXT NOT NULL,
  note         TEXT,
  monthly_fee  REAL NOT NULL DEFAULT 0,
  due_day      INTEGER NOT NULL DEFAULT 1,
  bank_name    TEXT,
  bank_acc     TEXT,
  bank_owner   TEXT
, age INTEGER, health_info TEXT, allergy TEXT, emergency_contact TEXT, emergency_phone TEXT, admission_date TEXT, photo_key TEXT, bank_account_id TEXT REFERENCES bank_accounts(id) ON DELETE SET NULL, moved_out INTEGER NOT NULL DEFAULT 0, move_out_date TEXT, due_date_override TEXT NOT NULL DEFAULT '', withholding_override TEXT NOT NULL DEFAULT '', address TEXT NOT NULL DEFAULT '', phone TEXT NOT NULL DEFAULT '', tax_id TEXT NOT NULL DEFAULT '');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrngq4ln26qqd','mrm0nhoxgn7rg','ยายใจดี','',23000,16,'ธนาคารกสิกรไทย','212-8-85185-5','นางบำเพ็ญ ไชยอุดม',77,'','','','','2026-06-16','',NULL,0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrov5p8rub4ak','mrm1sbqy8v3zb','คุณยายวรรณา เตชะมนูญ','',22000,1,'ธนาคารกรุงศรีอยุธยา','084-9-14210-9','สุกัญญา ไค่นุ่นนา',NULL,'','','','','2026-02-01','','mrn5ccnxrpzkm',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrov9hcgjdb42','mrm1sbqy8v3zb','คุณศรีจรรย์ นิตยประภา','',23000,28,'ธนาคารออมสิน','020-291825-188','นายธนาณัติ สินสุวรรณ์',NULL,'','','','','2026-04-29','','mrn583vx7rztw',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrovbzmxxjkkj','mrm1sbqy8v3zb','อากงเขียน','',21000,10,'ธนาคารไทยพาณิชย์','026-477062-5','ศิริพร แสงมณี',NULL,'','','','','2025-05-10','','mrn59cewwee63',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrovetpegn3d6','mrm1sbqy8v3zb','คุณยายวรรณา (แป้น) ตราโมท','',18000,9,'ธนาคารกรุงเทพ','197-073-9569','ปาจรีย์ เกิดประเสริฐ',NULL,'','','','','2022-07-09','','mrn5a6w1dpuzz',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrovh9pulla6o','mrm1sbqy8v3zb','อากงโมงัก (วัฒน์) แซ่โกว','',18500,17,'ธนาคารกรุงเทพ','197-073-9569','ปาจรีย์ เกิดประเสริฐ',NULL,'','','','','2022-08-17','','mrn5a6w1dpuzz',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrovlb9phnv2n','mrm1sbqy8v3zb','คุณสุทธิพงศ์ โอฬารสฤษดิ์กูล','',21000,28,'ธนาคารออมสิน','020-291825-188','นายธนาณัติ สินสุวรรณ์',NULL,'','','','','2025-11-28','','mrn583vx7rztw',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrovpnnway5bq','mrm1sbqy8v3zb','คุณยายอัจฉรา แซ่จิว','',19000,19,'ธนาคารไทยพาณิชย์','026-477062-5','ศิริพร แสงมณี',NULL,'','','','','2023-03-19','','mrn59cewwee63',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrovrfd5r0ra9','mrm1sbqy8v3zb','คุณอัจจิมา บุญอยู่คง','',19000,1,'ธนาคารกรุงเทพ','197-073-9569','ปาจรีย์ เกิดประเสริฐ',NULL,'','','','','2023-05-24','','mrn5a6w1dpuzz',0,NULL,'2023-06-01','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrovtah7hknwz','mrm1sbqy8v3zb','คุณยายโชติมา','',19000,28,'ธนาคารกรุงเทพ','197-073-9569','ปาจรีย์ เกิดประเสริฐ',NULL,'','','','','2023-05-28','','mrn5a6w1dpuzz',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrovvh43ycwa3','mrm1sbqy8v3zb','คุณยายธีรวัลย์','',22000,20,'ธนาคารไทยพาณิชย์','026-477062-5','ศิริพร แสงมณี',NULL,'','','','','2023-06-20','','mrn59cewwee63',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrovx52beab8m','mrm1sbqy8v3zb','คุณยายอาภรณ์ คติอนุรักษ์','',19000,16,'ธนาคารไทยพาณิชย์','026-477062-5','ศิริพร แสงมณี',NULL,'','','','','2025-01-16','','mrn59cewwee63',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrow0oy2sla7c','mrm1sbqy8v3zb','คุณยายทองดี','',21000,21,'ธนาคารกรุงเทพ','197-073-9569','ปาจรีย์ เกิดประเสริฐ',NULL,'','','','','2022-07-21','','mrn5a6w1dpuzz',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrow2k5t3jiaw','mrm1sbqy8v3zb','คุณยายหงษ์','',20000,27,'ธนาคารออมสิน','020-291825-188','นายธนาณัติ สินสุวรรณ์',NULL,'','','','','2023-06-27','','mrn583vx7rztw',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrow48wgastp6','mrm1sbqy8v3zb','คุณจงกลณี อ่อนละมุน','',23000,16,'ธนาคารออมสิน','020-291825-188','นายธนาณัติ สินสุวรรณ์',NULL,'','','','','2025-10-16','','mrn583vx7rztw',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrow69gijed58','mrm1sbqy8v3zb','คุณยายรำไพ','',20000,17,'ธนาคารไทยพาณิชย์','026-477062-5','ศิริพร แสงมณี',NULL,'','','','','2024-06-17','','mrn59cewwee63',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrow7our9akz0','mrm1sbqy8v3zb','คุณตาไพศาล','',22000,18,'ธนาคารออมสิน','020-291825-188','นายธนาณัติ สินสุวรรณ์',NULL,'','','','','2024-09-18','','mrn583vx7rztw',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrow94u2r3k4n','mrm1sbqy8v3zb','คุณยายเพิ่มศรี ฟักอังกูร','',23500,1,'ธนาคารไทยพาณิชย์','026-477062-5','ศิริพร แสงมณี',NULL,'','','','','2022-09-01','','mrn59cewwee63',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrowcieo9f25j','mrm1sbqy8v3zb','คุณพ่อวิชัย','',22000,22,'ธนาคารไทยพาณิชย์','026-477062-5','ศิริพร แสงมณี',NULL,'','','','','2025-06-22','','mrn59cewwee63',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrowe5c2tamon','mrm1sbqy8v3zb','คุณตาจรูญ รอดเจริญ','',22000,19,'ธนาคารกรุงศรีอยุธยา','084-9-14210-9','สุกัญญา ไค่นุ่นนา',NULL,'','','','','2026-04-19','','mrn5ccnxrpzkm',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrowfj04xtxc7','mrm1sbqy8v3zb','คุณอรวรรณ เพียรพิริยะ','',21000,27,'ธนาคารออมสิน','020-291825-188','นายธนาณัติ สินสุวรรณ์',NULL,'','','','','2026-03-27','','mrn583vx7rztw',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrpwnxz8i50o7','mrm0nhoxgn7rg','คุณแม่จงใจ ปิยะรัตน์','ลูกสาว คุณฝน',29000,18,'ธนาคารกสิกรไทย','212-8-85185-5','บำเพ็ญ ไชยอุดม',NULL,'ผ่าตัดช่องท้อง','','คุณฝน','0953752208','2026-07-18','','mrpx358n1sd2y',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrqktstrz1849','mrm0nhoxgn7rg','111','',23000,17,'ธนาคารกสิกรไทย','221-8-34321-2','บริษัท 2 อันดาเลวเนส จำกัด',NULL,'','','','','2026-07-17','','mrx0ejk84jwer',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrwyazghw25sk','mrm1sbqy8v3zb','คุณตาทดสอบ','',23000,23,'กสิกรไทย','221-8-34321-2','บริษัท 2 อันดาเวลเนส จำกัด',NULL,'','','','','2026-07-23','','mrx0cqwgbn9kc',0,NULL,'2026-07-23','always','-','099-125-1251','0000000000009');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrx99godaywco','mrm0nhoxgn7rg','คุณยายทดสอบ ลองบิล','',23000,10,'ธนาคารกสิกรไทย','221-8-34321-2','บริษัท 2 อันดาเลวเนส จำกัด',NULL,'','','','','2026-07-10','','mrx0ejk84jwer',0,NULL,'','','123 ซ.แคบ ถ.คอนกรีต แขวงจอมพล เขตจตุจักร กทม. 10900','099-125-1251','0000000000009');
CREATE TABLE entries (
  id       TEXT PRIMARY KEY,
  case_id  TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  ym       TEXT NOT NULL,   -- รูปแบบ 'YYYY-MM'
  date     TEXT,
  desc     TEXT NOT NULL,
  amount   REAL NOT NULL DEFAULT 0
, category TEXT);
INSERT INTO "entries" ("id","case_id","ym","date","desc","amount","category") VALUES('mrngte26a75dz','mrngq4ln26qqd','2026-07','2026-07-01','ค่าบริการหัตถการทางการพยาบาล — เจาะเลือด',1000,'procedure');
INSERT INTO "entries" ("id","case_id","ym","date","desc","amount","category") VALUES('mrnhcye7ob78e','mrngq4ln26qqd','2026-07','2026-07-06','ค่าบริการเจ้าหน้าที่พาไปพบแพทย์',800,'escort');
INSERT INTO "entries" ("id","case_id","ym","date","desc","amount","category") VALUES('mrojxcvcwgz2j','mrngq4ln26qqd','2026-07','2026-07-16','ค่าบริการเจ้าหน้าที่พาไปพบแพทย์',800,'escort');
INSERT INTO "entries" ("id","case_id","ym","date","desc","amount","category") VALUES('mrt99ncfbaxi5','mrovvh43ycwa3','2026-07','2026-06-21','ค่าบริการไฟฟ้า (ที่นอนลม)',500,'other');
INSERT INTO "entries" ("id","case_id","ym","date","desc","amount","category") VALUES('mrx18hcjn2sv3','mrwyazghw25sk','2026-07','2026-07-01','ค่าบริการจัดหาเวชภัณฑ์',500,'medicine');
INSERT INTO "entries" ("id","case_id","ym","date","desc","amount","category") VALUES('mrx18hcjmi7mt','mrwyazghw25sk','2026-07','2026-07-01','ค่าบริการจัดหาเวชภัณฑ์ (service charge 10% ของยอดเวชภัณฑ์รวม)',50,'medicine_service_charge');
CREATE TABLE payments (
  case_id      TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  ym           TEXT NOT NULL,   -- รูปแบบ 'YYYY-MM'
  paid         INTEGER NOT NULL DEFAULT 0,
  paid_date    TEXT,
  paid_amount  REAL,
  method       TEXT,
  invoice_no   TEXT,
  receipt_no   TEXT, discount REAL DEFAULT 0, slip_key TEXT,
  PRIMARY KEY (case_id, ym)
);
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrngq4ln26qqd','2026-07',0,NULL,NULL,'','INV-M02-2569-0001','',0,'');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrov5p8rub4ak','2026-07',1,'2026-07-05',22000,'โอนเงินผ่านธนาคาร','INV-M01-2569-0001','RCT-M01-2569-0001',0,'slip-mrov5p8rub4ak-2026-07-1784301377405.jpeg');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrov9hcgjdb42','2026-07',0,NULL,NULL,'','INV-M01-2569-0001','',0,'');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrovbzmxxjkkj','2026-07',1,'2026-07-13',20700,'โอนเงินผ่านธนาคาร','INV-M01-2569-0002','RCT-M01-2569-0001',300,'slip-mrovbzmxxjkkj-2026-07-1784301522984.jpeg');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrovetpegn3d6','2026-07',1,'2026-07-01',18000,'โอนเงินผ่านธนาคาร','','RCT-M01-2569-0001',0,'slip-mrovetpegn3d6-2026-07-1784301821993.jpeg');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrovlb9phnv2n','2026-07',0,NULL,NULL,'','INV-M01-2569-0001','',0,'');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrovpnnway5bq','2026-07',0,NULL,NULL,'','INV-M01-2569-0002','',0,'');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrqktstrz1849','2026-07',1,'2026-07-18',23000,'โอนเงินผ่านธนาคาร','','',0,'');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrpwnxz8i50o7','2026-07',0,NULL,NULL,'','','',0,'');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrow94u2r3k4n','2026-07',1,'2026-07-02',23500,'โอนเงินผ่านธนาคาร','','RCT-M01-2569-0001',0,'slip-mrow94u2r3k4n-2026-07-1784429849845.jpeg');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrovh9pulla6o','2026-07',1,'2026-07-13',18500,'โอนเงินผ่านธนาคาร','','RCT-M01-2569-0002',0,'slip-mrovh9pulla6o-2026-07-1784429931628.jpeg');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrow7our9akz0','2026-07',1,'2026-07-19',22000,'โอนเงินผ่านธนาคาร','','RCT-M01-2569-0003',0,'slip-mrow7our9akz0-2026-07-1784430001612.jpeg');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrovrfd5r0ra9','2026-07',1,'2026-07-01',19000,'โอนเงินผ่านธนาคาร','INV-M01-2569-0003','RCT-M01-2569-0004',0,'');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrovvh43ycwa3','2026-07',1,'2026-07-20',22500,'โอนเงินผ่านธนาคาร','INV-M01-2569-0004','RCT-M01-2569-0005',0,'slip-mrovvh43ycwa3-2026-07-1784553885910.jpeg');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrovx52beab8m','2026-07',1,'2026-07-19',19000,'โอนเงินผ่านธนาคาร','','RCT-M01-2569-0006',0,'slip-mrovx52beab8m-2026-07-1784553981739.jpeg');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrow69gijed58','2026-07',1,'2026-07-18',19700,'เงินสด','','RCT-M01-2569-0008',300,'slip-mrow69gijed58-2026-07-1784554130581.jpeg');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrowe5c2tamon','2026-07',0,NULL,NULL,'','INV-M01-2569-0005','',0,'');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrow0oy2sla7c','2026-07',1,'2026-07-21',21000,'โอนเงินผ่านธนาคาร','','RCT-M01-2569-0009',0,'slip-mrow0oy2sla7c-2026-07-1784607324252.jpeg');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrowcieo9f25j','2026-07',0,NULL,NULL,'','INV-M01-2569-0006','',0,'');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrovtah7hknwz','2026-07',0,NULL,NULL,'','INV-M01-2569-0007','',0,'');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrwyazghw25sk','2026-07',0,NULL,NULL,'','INV-M01-2569-0008','',0,'');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrx99godaywco','2026-07',0,NULL,NULL,'','INV-M02-2569-0001','',0,'');
INSERT INTO "payments" ("case_id","ym","paid","paid_date","paid_amount","method","invoice_no","receipt_no","discount","slip_key") VALUES('mrow48wgastp6','2026-07',0,NULL,NULL,NULL,'INV-M01-2569-0009',NULL,0,NULL);
CREATE TABLE users (
  id            TEXT PRIMARY KEY,
  username      TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  salt          TEXT NOT NULL,
  display_name  TEXT,
  role          TEXT NOT NULL DEFAULT 'staff',   -- 'admin' | 'staff'
  org_id        TEXT REFERENCES orgs(id) ON DELETE SET NULL,
  branch_id     TEXT REFERENCES branches(id) ON DELETE SET NULL
);
INSERT INTO "users" ("id","username","password_hash","salt","display_name","role","org_id","branch_id") VALUES('user_f874b63862250a5a','admin1','f219978d20c9c115547fc650583c19d2f83521423957c33a9258cdecb1c63afa','2c2ee9ce2bb058ab29eb3288c31b1032','ผู้ดูแลระบบ','admin',NULL,NULL);
INSERT INTO "users" ("id","username","password_hash","salt","display_name","role","org_id","branch_id") VALUES('user_ac2cd86d8b7b525e','pla','0f47122ac8758c21298e7bf46b49922cdcbc41102cb52455a1b546136f295f9c','78e6ced4b65a46cdebdc89337753c7eb','pla','manager',NULL,NULL);
INSERT INTO "users" ("id","username","password_hash","salt","display_name","role","org_id","branch_id") VALUES('user_9830221aca81f73c','Masu01','2f039393cefaa634a21781cebe68e778e783d7a9782997a29dfb0f054b3354eb','52e4bcc8af69dc40300b02c22a9661be','Masu01','staff',NULL,NULL);
INSERT INTO "users" ("id","username","password_hash","salt","display_name","role","org_id","branch_id") VALUES('user_a0c36fd904ddfce2','BossNu','39c057461a4edbf786a7728097995066acf0cea48cc931b79ee54fd6db972e1f','32e8ba454e3e187dfbb5a2c54e6001f4','BossNu','admin',NULL,NULL);
INSERT INTO "users" ("id","username","password_hash","salt","display_name","role","org_id","branch_id") VALUES('user_e5d1bb7d7a0b35e6','Manager','52a8140ace4fe5a1f5e2cdd617270695f409296905b0a4e10b11eb97671f9034','a54ac996bdd31a0700ad22cd4fe2bbcd','ทดสอบ','manager',NULL,NULL);
INSERT INTO "users" ("id","username","password_hash","salt","display_name","role","org_id","branch_id") VALUES('user_36d1991e4d6d2a91','Staff','40ddf9cab69d2897bb984e9db0fcfadd97e092ef6b0c5dd683a78b754d1113d7','85eb8298350349b3fe3244a04e0df9bf','พนักงาน','staff',NULL,NULL);
INSERT INTO "users" ("id","username","password_hash","salt","display_name","role","org_id","branch_id") VALUES('user_fca8fc76c6e5d2ce','Outsource','3c9075514d06fa502d0699b73adc6e1ebe543f58ceb3ed7d33a5928ab88a61f5','8449f1cdf8fb19b1050b7f08314b2189','คนลงค่าใช้จ่าย','accountant',NULL,NULL);
CREATE TABLE bank_accounts (
  id         TEXT PRIMARY KEY,
  branch_id  TEXT NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  bank_name  TEXT NOT NULL,
  bank_acc   TEXT NOT NULL,
  bank_owner TEXT
, doc_numbering TEXT NOT NULL DEFAULT 'shared', withholding_tax TEXT NOT NULL DEFAULT 'none');
INSERT INTO "bank_accounts" ("id","branch_id","bank_name","bank_acc","bank_owner","doc_numbering","withholding_tax") VALUES('mrn53hjk8u78a','mrm0nhoxgn7rg','ธนาคารทหารไทยธนชาติ','289-2-10846-1','นายธนาณัติ สินสุวรรณ์','shared','none');
INSERT INTO "bank_accounts" ("id","branch_id","bank_name","bank_acc","bank_owner","doc_numbering","withholding_tax") VALUES('mrn55clsq9dcj','mrm0nhoxgn7rg','ธนาคารทหารไทยธนชาติ(TTB)','928-2-04468-5','นายณัฐเศรษฐ เบญจภัสสรสิริ','shared','none');
INSERT INTO "bank_accounts" ("id","branch_id","bank_name","bank_acc","bank_owner","doc_numbering","withholding_tax") VALUES('mrn583vx7rztw','mrm1sbqy8v3zb','ธนาคารออมสิน','020-291825-188','นายธนาณัติ สินสุวรรณ์','shared','none');
INSERT INTO "bank_accounts" ("id","branch_id","bank_name","bank_acc","bank_owner","doc_numbering","withholding_tax") VALUES('mrn59cewwee63','mrm1sbqy8v3zb','ธนาคารไทยพาณิชย์','026-477062-5','ศิริพร แสงมณี','shared','none');
INSERT INTO "bank_accounts" ("id","branch_id","bank_name","bank_acc","bank_owner","doc_numbering","withholding_tax") VALUES('mrn5a6w1dpuzz','mrm1sbqy8v3zb','ธนาคารกรุงเทพ','197-073-9569','ปาจรีย์ เกิดประเสริฐ','shared','none');
INSERT INTO "bank_accounts" ("id","branch_id","bank_name","bank_acc","bank_owner","doc_numbering","withholding_tax") VALUES('mrn5ccnxrpzkm','mrm1sbqy8v3zb','ธนาคารกรุงศรีอยุธยา','084-9-14210-9','สุกัญญา ไค่นุ่นนา','shared','none');
INSERT INTO "bank_accounts" ("id","branch_id","bank_name","bank_acc","bank_owner","doc_numbering","withholding_tax") VALUES('mrpx358n1sd2y','mrm0nhoxgn7rg','ธนาคารกสิกรไทย','212-8-85185-5','บำเพ็ญ ไชยอุดม','none','none');
INSERT INTO "bank_accounts" ("id","branch_id","bank_name","bank_acc","bank_owner","doc_numbering","withholding_tax") VALUES('mrx0cqwgbn9kc','mrm1sbqy8v3zb','กสิกรไทย','221-8-34321-2','บริษัท 2 อันดาเวลเนส จำกัด','separate','apply');
INSERT INTO "bank_accounts" ("id","branch_id","bank_name","bank_acc","bank_owner","doc_numbering","withholding_tax") VALUES('mrx0ejk84jwer','mrm0nhoxgn7rg','ธนาคารกสิกรไทย','221-8-34321-2','บริษัท 2 อันดาเลวเนส จำกัด','separate','apply');
CREATE TABLE fee_toggles (
  case_id  TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  ym       TEXT NOT NULL,
  included INTEGER NOT NULL DEFAULT 1,
  PRIMARY KEY (case_id, ym)
);
INSERT INTO "fee_toggles" ("case_id","ym","included") VALUES('mrpwnxz8i50o7','2026-07',1);
CREATE TABLE adhoc_bills (
  id           TEXT PRIMARY KEY,
  case_id      TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  bill_date    TEXT NOT NULL,
  note         TEXT,
  discount     REAL DEFAULT 0,
  paid         INTEGER NOT NULL DEFAULT 0,
  paid_date    TEXT,
  paid_amount  REAL,
  method       TEXT,
  invoice_no   TEXT,
  receipt_no   TEXT,
  slip_key     TEXT
);
INSERT INTO "adhoc_bills" ("id","case_id","bill_date","note","discount","paid","paid_date","paid_amount","method","invoice_no","receipt_no","slip_key") VALUES('mrpx4b1m0p4yp','mrpwnxz8i50o7','2026-07-18','จองเตียง',0,1,'2026-07-18',5000,'โอนเงินผ่านธนาคาร','','','slip-adhoc-mrpx4b1m0p4yp-1784378153423.jpeg');
INSERT INTO "adhoc_bills" ("id","case_id","bill_date","note","discount","paid","paid_date","paid_amount","method","invoice_no","receipt_no","slip_key") VALUES('mrqkt1hqbpqit','mrngq4ln26qqd','2026-07-18','',0,0,NULL,NULL,'','INV-M02-2569-0002','','');
INSERT INTO "adhoc_bills" ("id","case_id","bill_date","note","discount","paid","paid_date","paid_amount","method","invoice_no","receipt_no","slip_key") VALUES('mrqkua967sva8','mrqktstrz1849','2026-07-18','',0,0,NULL,NULL,'','','','');
INSERT INTO "adhoc_bills" ("id","case_id","bill_date","note","discount","paid","paid_date","paid_amount","method","invoice_no","receipt_no","slip_key") VALUES('mrwy8ubt99eeo','mrqktstrz1849','2026-07-23','',0,0,NULL,NULL,'','','','');
CREATE TABLE adhoc_bill_items (
  id       TEXT PRIMARY KEY,
  bill_id  TEXT NOT NULL REFERENCES adhoc_bills(id) ON DELETE CASCADE,
  desc     TEXT NOT NULL,
  amount   REAL NOT NULL DEFAULT 0,
  category TEXT
);
INSERT INTO "adhoc_bill_items" ("id","bill_id","desc","amount","category") VALUES('mrpx4otqb2yrr','mrpx4b1m0p4yp','ค่ามัดจำการให้บริการ — (จองเตียง)',5000,'deposit');
INSERT INTO "adhoc_bill_items" ("id","bill_id","desc","amount","category") VALUES('mrqkt7l3dhq69','mrqkt1hqbpqit','ค่าบริการเจ้าหน้าที่พาไปพบแพทย์',800,'escort');
INSERT INTO "adhoc_bill_items" ("id","bill_id","desc","amount","category") VALUES('mrqkulv4n8kh2','mrqkua967sva8','ค่ามัดจำการให้บริการ — จองเตียง',5000,'deposit');
INSERT INTO "adhoc_bill_items" ("id","bill_id","desc","amount","category") VALUES('mrwy93lly2ee0','mrwy8ubt99eeo','ค่าบริการเจ้าหน้าที่พาไปพบแพทย์',2000,'escort');
CREATE TABLE user_branch_access (
  user_id   TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  branch_id TEXT NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, branch_id)
);
INSERT INTO "user_branch_access" ("user_id","branch_id") VALUES('user_e5d1bb7d7a0b35e6','mrxntglf98zew');
INSERT INTO "user_branch_access" ("user_id","branch_id") VALUES('user_36d1991e4d6d2a91','mrxntglf98zew');
INSERT INTO "user_branch_access" ("user_id","branch_id") VALUES('user_fca8fc76c6e5d2ce','mrxntglf98zew');
INSERT INTO "user_branch_access" ("user_id","branch_id") VALUES('user_ac2cd86d8b7b525e','mrm0nhoxgn7rg');
INSERT INTO "user_branch_access" ("user_id","branch_id") VALUES('user_ac2cd86d8b7b525e','mrn74e5733z9c');
INSERT INTO "user_branch_access" ("user_id","branch_id") VALUES('user_ac2cd86d8b7b525e','mrm1sbqy8v3zb');
INSERT INTO "user_branch_access" ("user_id","branch_id") VALUES('user_ac2cd86d8b7b525e','mrxntglf98zew');
INSERT INTO "user_branch_access" ("user_id","branch_id") VALUES('user_9830221aca81f73c','mrm1sbqy8v3zb');
CREATE TABLE appointments (
  id      TEXT PRIMARY KEY,
  case_id TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  date    TEXT NOT NULL,
  note    TEXT,
  status  TEXT NOT NULL DEFAULT 'scheduled'
);
CREATE TABLE IF NOT EXISTS "doc_sequences" (
  branch_id TEXT NOT NULL,
  doc_type TEXT NOT NULL,
  year INTEGER NOT NULL,
  bank_account_id TEXT NOT NULL DEFAULT '',
  last_seq INTEGER NOT NULL DEFAULT 0,
  UNIQUE(branch_id, doc_type, year, bank_account_id)
);
INSERT INTO "doc_sequences" ("branch_id","doc_type","year","bank_account_id","last_seq") VALUES('mrm1sbqy8v3zb','invoice',2569,'',9);
INSERT INTO "doc_sequences" ("branch_id","doc_type","year","bank_account_id","last_seq") VALUES('mrm0nhoxgn7rg','invoice',2569,'',2);
INSERT INTO "doc_sequences" ("branch_id","doc_type","year","bank_account_id","last_seq") VALUES('mrm1sbqy8v3zb','receipt',2569,'',9);
INSERT INTO "doc_sequences" ("branch_id","doc_type","year","bank_account_id","last_seq") VALUES('mrm0nhoxgn7rg','invoice',2569,'mrx0ejk84jwer',1);
CREATE TABLE medication_items (
  id TEXT PRIMARY KEY,
  branch_id TEXT NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('drug','medical_supply','consumable')),
  unit TEXT NOT NULL,                 -- เม็ด, ขวด, ชิ้น, กล่อง, แผ่น ฯลฯ
  strength TEXT,                      -- ความแรงยา เช่น 500mg (เว้นว่างได้ถ้าไม่ใช่ยา)
  reorder_threshold REAL NOT NULL DEFAULT 0,
  current_stock REAL NOT NULL DEFAULT 0,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
, owner_type TEXT NOT NULL DEFAULT 'central', case_id TEXT REFERENCES cases(id) ON DELETE CASCADE);
INSERT INTO "medication_items" ("id","branch_id","name","category","unit","strength","reorder_threshold","current_stock","is_active","created_at","updated_at","owner_type","case_id") VALUES('4dfe7e2e-8aac-4e49-8339-da194f70ec8a','mrm1sbqy8v3zb','ยาความดัน','drug','เม็ด',NULL,5,60,1,'2026-07-23 15:45:49','2026-07-25 03:29:09','personal','mrwyazghw25sk');
INSERT INTO "medication_items" ("id","branch_id","name","category","unit","strength","reorder_threshold","current_stock","is_active","created_at","updated_at","owner_type","case_id") VALUES('20a85d9d-7279-4801-a6fe-9f2c2adf0615','mrm1sbqy8v3zb','แพมเพิส','medical_supply','ชิ้น',NULL,10,60,1,'2026-07-23 15:46:51','2026-07-25 03:29:23','personal','mrwyazghw25sk');
INSERT INTO "medication_items" ("id","branch_id","name","category","unit","strength","reorder_threshold","current_stock","is_active","created_at","updated_at","owner_type","case_id") VALUES('22ab494f-33da-43d9-957f-430aff3dba7a','mrm1sbqy8v3zb','ยา1','drug','เม็ด',NULL,5,90,1,'2026-07-23 15:47:26','2026-07-26 15:04:02','personal','mrwyazghw25sk');
INSERT INTO "medication_items" ("id","branch_id","name","category","unit","strength","reorder_threshold","current_stock","is_active","created_at","updated_at","owner_type","case_id") VALUES('7cebff08-c88c-4afd-8760-2a3f246f7a8c','mrm1sbqy8v3zb','ยา2','drug','เม็ด',NULL,5,90,1,'2026-07-23 15:47:43','2026-07-26 15:04:24','personal','mrwyazghw25sk');
INSERT INTO "medication_items" ("id","branch_id","name","category","unit","strength","reorder_threshold","current_stock","is_active","created_at","updated_at","owner_type","case_id") VALUES('567c0606-668a-4c86-83e3-c6b29a425f10','mrm1sbqy8v3zb','BroMHExine','drug','20','8',0,130,1,'2026-07-25 03:42:15','2026-07-26 15:03:13','personal','mrwyazghw25sk');
CREATE TABLE medication_schedules (
  id TEXT PRIMARY KEY,
  case_id TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  item_id TEXT NOT NULL REFERENCES medication_items(id),
  dose TEXT NOT NULL,                 -- เช่น "1 เม็ด", "5 มล."
  route TEXT,                         -- oral, IV, IM, topical ฯลฯ
  times_per_day TEXT NOT NULL,        -- เช่น "08:00,12:00,18:00,22:00" (comma-separated)
  start_date TEXT NOT NULL,
  end_date TEXT,                      -- NULL = ให้ต่อเนื่องไม่มีกำหนด
  is_active INTEGER NOT NULL DEFAULT 1,
  prescribed_by TEXT,
  notes TEXT,
  created_at TEXT DEFAULT (datetime('now'))
, time_slots TEXT, meal_relation TEXT);
INSERT INTO "medication_schedules" ("id","case_id","item_id","dose","route","times_per_day","start_date","end_date","is_active","prescribed_by","notes","created_at","time_slots","meal_relation") VALUES('261bad5d-3239-4dff-b5ae-6597cd223422','mrwyazghw25sk','567c0606-668a-4c86-83e3-c6b29a425f10','1',NULL,'09:00,13:00,18:00,22:00','2026-07-26',NULL,1,NULL,NULL,'2026-07-26 15:03:13','morning,noon,evening,night','before_meal');
INSERT INTO "medication_schedules" ("id","case_id","item_id","dose","route","times_per_day","start_date","end_date","is_active","prescribed_by","notes","created_at","time_slots","meal_relation") VALUES('2c323e54-d50f-4535-a385-d3fcc194f5c4','mrwyazghw25sk','22ab494f-33da-43d9-957f-430aff3dba7a','1',NULL,'09:00,18:00','2026-07-26',NULL,1,NULL,NULL,'2026-07-26 15:04:03','morning,evening','after_meal');
INSERT INTO "medication_schedules" ("id","case_id","item_id","dose","route","times_per_day","start_date","end_date","is_active","prescribed_by","notes","created_at","time_slots","meal_relation") VALUES('5db80fb5-b705-493f-94ad-3f279367ffa1','mrwyazghw25sk','7cebff08-c88c-4afd-8760-2a3f246f7a8c','1',NULL,'09:00,18:00','2026-07-26',NULL,1,NULL,NULL,'2026-07-26 15:04:24','morning,evening','before_meal');
CREATE TABLE branch_name_aliases (
  payroll_branch_name TEXT PRIMARY KEY,
  branch_id TEXT NOT NULL REFERENCES branches(id) ON DELETE CASCADE
);
CREATE TABLE push_subscriptions (
  id TEXT PRIMARY KEY,
  branch_id TEXT NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  employee_id TEXT,
  endpoint TEXT NOT NULL UNIQUE,
  p256dh TEXT NOT NULL,
  auth TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);
CREATE TABLE ms_staff_accounts (
  id TEXT PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  password_salt TEXT NOT NULL,
  display_name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin','manager','staff')),
  branch_id TEXT REFERENCES branches(id) ON DELETE SET NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT DEFAULT (datetime('now'))
);
INSERT INTO "ms_staff_accounts" ("id","username","password_hash","password_salt","display_name","role","branch_id","is_active","created_at") VALUES('01ef424d-e88a-44b8-a93e-f559fbaa919a','admin1','8_1gRjWPU13m6uiF6dkrUgXZlSbv6fS4LQUfXmYSgww','iStyPNXFPcjAWHS-ozkcvg','admin1','admin',NULL,1,'2026-07-22 08:33:28');
INSERT INTO "ms_staff_accounts" ("id","username","password_hash","password_salt","display_name","role","branch_id","is_active","created_at") VALUES('98284a53-6360-4186-92f6-8160d62a5bcd','Masu02','VRTUUOWgLpQbq-kudJgwXciy0r53zC4sgYkMRijVYdc','qlsmI3QO3h1GnEo8vnALmQ','มาสุ02','staff',NULL,1,'2026-07-22 08:57:21');
INSERT INTO "ms_staff_accounts" ("id","username","password_hash","password_salt","display_name","role","branch_id","is_active","created_at") VALUES('1ed2abd7-746d-4290-af2b-bd003cabc1ae','pla','QXtck9Yw0YSj_FzqU_NOyKOhAkgGi5z4Xp8k3gScIns','Iw4sJ8T2geMO7Q2ABpAbTg','ปลา','manager',NULL,1,'2026-07-22 08:58:01');
INSERT INTO "ms_staff_accounts" ("id","username","password_hash","password_salt","display_name","role","branch_id","is_active","created_at") VALUES('583d86a2-bdc5-4c2a-936c-310f9168788e','Masu01','jzHNUwmM3WOoVchb4tjTMseG---21dIe-DRg_Oke_ms','DxWaT2IkrzW7QN9B0M7HNQ','มาสุ01','staff','mrm1sbqy8v3zb',1,'2026-07-25 03:23:50');
CREATE TABLE stock_transactions (
  id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL REFERENCES medication_items(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('receive','dispense','adjust')),
  quantity REAL NOT NULL,
  lot_no TEXT,
  expiry_date TEXT,
  case_id TEXT REFERENCES cases(id) ON DELETE SET NULL,
  reference_note TEXT,
  performed_by TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  voided INTEGER NOT NULL DEFAULT 0,
  void_reason TEXT
);
INSERT INTO "stock_transactions" ("id","item_id","type","quantity","lot_no","expiry_date","case_id","reference_note","performed_by","created_at","voided","void_reason") VALUES('733bd7ea-ade2-4bf9-b325-ee279dbf9ae6','22ab494f-33da-43d9-957f-430aff3dba7a','receive',60,NULL,NULL,NULL,NULL,'T','2026-07-24 02:48:08',0,NULL);
INSERT INTO "stock_transactions" ("id","item_id","type","quantity","lot_no","expiry_date","case_id","reference_note","performed_by","created_at","voided","void_reason") VALUES('2790ea3a-679c-4b0f-9b65-736d8395f4da','7cebff08-c88c-4afd-8760-2a3f246f7a8c','receive',60,NULL,NULL,NULL,NULL,NULL,'2026-07-25 03:28:56',0,NULL);
INSERT INTO "stock_transactions" ("id","item_id","type","quantity","lot_no","expiry_date","case_id","reference_note","performed_by","created_at","voided","void_reason") VALUES('c7deed48-d499-4570-ad46-73f4f6d3bc33','4dfe7e2e-8aac-4e49-8339-da194f70ec8a','receive',60,NULL,NULL,NULL,NULL,NULL,'2026-07-25 03:29:09',0,NULL);
INSERT INTO "stock_transactions" ("id","item_id","type","quantity","lot_no","expiry_date","case_id","reference_note","performed_by","created_at","voided","void_reason") VALUES('a1a60c42-d254-4217-8d4b-8747060d6ffe','20a85d9d-7279-4801-a6fe-9f2c2adf0615','receive',60,NULL,NULL,NULL,NULL,NULL,'2026-07-25 03:29:23',0,NULL);
INSERT INTO "stock_transactions" ("id","item_id","type","quantity","lot_no","expiry_date","case_id","reference_note","performed_by","created_at","voided","void_reason") VALUES('4ba6ad71-bc5e-4a4d-b8b1-8d6e5124078c','567c0606-668a-4c86-83e3-c6b29a425f10','receive',20,NULL,NULL,NULL,NULL,NULL,'2026-07-25 04:04:59',0,NULL);
INSERT INTO "stock_transactions" ("id","item_id","type","quantity","lot_no","expiry_date","case_id","reference_note","performed_by","created_at","voided","void_reason") VALUES('4e3cf5f7-5805-40ce-bbb5-71c39426042e','567c0606-668a-4c86-83e3-c6b29a425f10','receive',50,NULL,NULL,NULL,NULL,NULL,'2026-07-25 04:07:46',0,NULL);
INSERT INTO "stock_transactions" ("id","item_id","type","quantity","lot_no","expiry_date","case_id","reference_note","performed_by","created_at","voided","void_reason") VALUES('e37a8e8b-4ad8-45b4-8aca-146f909873d2','567c0606-668a-4c86-83e3-c6b29a425f10','receive',60,NULL,NULL,NULL,NULL,NULL,'2026-07-26 15:03:13',0,NULL);
INSERT INTO "stock_transactions" ("id","item_id","type","quantity","lot_no","expiry_date","case_id","reference_note","performed_by","created_at","voided","void_reason") VALUES('1aacb6d7-7a15-40c9-8e9a-633e025e39f9','22ab494f-33da-43d9-957f-430aff3dba7a','receive',30,NULL,NULL,NULL,NULL,NULL,'2026-07-26 15:04:02',0,NULL);
INSERT INTO "stock_transactions" ("id","item_id","type","quantity","lot_no","expiry_date","case_id","reference_note","performed_by","created_at","voided","void_reason") VALUES('07700dc1-b92e-4450-bbdf-ebe8f829ee11','7cebff08-c88c-4afd-8760-2a3f246f7a8c','receive',30,NULL,NULL,NULL,NULL,NULL,'2026-07-26 15:04:24',0,NULL);
CREATE TABLE medication_admin_logs (
  id TEXT PRIMARY KEY,
  schedule_id TEXT NOT NULL REFERENCES medication_schedules(id) ON DELETE CASCADE,
  case_id TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  item_id TEXT NOT NULL REFERENCES medication_items(id),
  scheduled_time TEXT NOT NULL,
  actual_time TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','given','missed','refused','held')),
  given_by TEXT,
  notes TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  stock_transaction_id TEXT REFERENCES stock_transactions(id),
  notified_at TEXT
, slot_key TEXT);
INSERT INTO "medication_admin_logs" ("id","schedule_id","case_id","item_id","scheduled_time","actual_time","status","given_by","notes","created_at","stock_transaction_id","notified_at","slot_key") VALUES('72c6694f-24c3-47fb-82cb-8941b680e59a','261bad5d-3239-4dff-b5ae-6597cd223422','mrwyazghw25sk','567c0606-668a-4c86-83e3-c6b29a425f10','2026-07-26 09:00',NULL,'pending',NULL,NULL,'2026-07-26 15:03:22',NULL,NULL,'morning');
INSERT INTO "medication_admin_logs" ("id","schedule_id","case_id","item_id","scheduled_time","actual_time","status","given_by","notes","created_at","stock_transaction_id","notified_at","slot_key") VALUES('1da25020-c3a7-4b85-b896-f6781bf13926','261bad5d-3239-4dff-b5ae-6597cd223422','mrwyazghw25sk','567c0606-668a-4c86-83e3-c6b29a425f10','2026-07-26 13:00',NULL,'pending',NULL,NULL,'2026-07-26 15:03:22',NULL,NULL,'noon');
INSERT INTO "medication_admin_logs" ("id","schedule_id","case_id","item_id","scheduled_time","actual_time","status","given_by","notes","created_at","stock_transaction_id","notified_at","slot_key") VALUES('faedbc92-1edc-48fa-8fba-e1a8549283db','261bad5d-3239-4dff-b5ae-6597cd223422','mrwyazghw25sk','567c0606-668a-4c86-83e3-c6b29a425f10','2026-07-26 18:00',NULL,'pending',NULL,NULL,'2026-07-26 15:03:22',NULL,NULL,'evening');
INSERT INTO "medication_admin_logs" ("id","schedule_id","case_id","item_id","scheduled_time","actual_time","status","given_by","notes","created_at","stock_transaction_id","notified_at","slot_key") VALUES('f7298d3e-31c0-4f3d-ae0a-0d7d75ee0584','261bad5d-3239-4dff-b5ae-6597cd223422','mrwyazghw25sk','567c0606-668a-4c86-83e3-c6b29a425f10','2026-07-26 22:00',NULL,'pending',NULL,NULL,'2026-07-26 15:03:22',NULL,NULL,'night');
INSERT INTO "medication_admin_logs" ("id","schedule_id","case_id","item_id","scheduled_time","actual_time","status","given_by","notes","created_at","stock_transaction_id","notified_at","slot_key") VALUES('1ad1057b-7073-4771-affa-429518585339','2c323e54-d50f-4535-a385-d3fcc194f5c4','mrwyazghw25sk','22ab494f-33da-43d9-957f-430aff3dba7a','2026-07-26 09:00',NULL,'pending',NULL,NULL,'2026-07-26 15:04:31',NULL,NULL,'morning');
INSERT INTO "medication_admin_logs" ("id","schedule_id","case_id","item_id","scheduled_time","actual_time","status","given_by","notes","created_at","stock_transaction_id","notified_at","slot_key") VALUES('f5edae36-083d-449e-93b0-1870c377d4aa','2c323e54-d50f-4535-a385-d3fcc194f5c4','mrwyazghw25sk','22ab494f-33da-43d9-957f-430aff3dba7a','2026-07-26 18:00',NULL,'pending',NULL,NULL,'2026-07-26 15:04:31',NULL,NULL,'evening');
INSERT INTO "medication_admin_logs" ("id","schedule_id","case_id","item_id","scheduled_time","actual_time","status","given_by","notes","created_at","stock_transaction_id","notified_at","slot_key") VALUES('c96dcf6a-eaf2-4def-9515-87a7d5156c80','5db80fb5-b705-493f-94ad-3f279367ffa1','mrwyazghw25sk','7cebff08-c88c-4afd-8760-2a3f246f7a8c','2026-07-26 09:00',NULL,'pending',NULL,NULL,'2026-07-26 15:04:31',NULL,NULL,'morning');
INSERT INTO "medication_admin_logs" ("id","schedule_id","case_id","item_id","scheduled_time","actual_time","status","given_by","notes","created_at","stock_transaction_id","notified_at","slot_key") VALUES('c4899829-e265-407c-9964-1b7bd9ff200e','5db80fb5-b705-493f-94ad-3f279367ffa1','mrwyazghw25sk','7cebff08-c88c-4afd-8760-2a3f246f7a8c','2026-07-26 18:00',NULL,'pending',NULL,NULL,'2026-07-26 15:04:31',NULL,NULL,'evening');
CREATE TABLE vital_signs (
  id TEXT PRIMARY KEY,
  case_id TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  recorded_at TEXT NOT NULL DEFAULT (datetime('now')),
  bp_systolic INTEGER,
  bp_diastolic INTEGER,
  temperature_c REAL,
  pulse_rate INTEGER,
  resp_rate INTEGER,
  spo2 INTEGER,
  blood_sugar REAL,
  other_symptoms TEXT,
  recorded_by TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);
CREATE TABLE equipment_items (
  id TEXT PRIMARY KEY,
  branch_id TEXT NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  asset_number TEXT,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  vendor TEXT,
  price REAL,
  purchase_date TEXT,
  warranty_expiry TEXT,
  status TEXT NOT NULL DEFAULT 'usable'
         CHECK (status IN ('usable','broken','repairing','disposed')),
  notes TEXT,
  created_by TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
, brand_model TEXT, purchase_source TEXT, issue_note TEXT);
INSERT INTO "equipment_items" ("id","branch_id","asset_number","name","category","vendor","price","purchase_date","warranty_expiry","status","notes","created_by","created_at","updated_at","brand_model","purchase_source","issue_note") VALUES('47bb9b2e-e184-4bcf-9131-f02db0ef73ea','mrm1sbqy8v3zb','B-01-001','เตียง 2 ไกร์ รุ่นแรก','เฟอร์นิเจอร์','-',9000,'2022-02-24',NULL,'usable',NULL,NULL,'2026-07-24 06:58:37','2026-07-24 07:00:07',NULL,NULL,NULL);
INSERT INTO "equipment_items" ("id","branch_id","asset_number","name","category","vendor","price","purchase_date","warranty_expiry","status","notes","created_by","created_at","updated_at","brand_model","purchase_source","issue_note") VALUES('2afc4844-e3ee-4c3f-a8ef-bca6ae17967f','mrm1sbqy8v3zb','TV-01-32-001','TV 32 "','เครื่องใช้ไฟฟ้า','Homepro',4000,'2024-03-24',NULL,'usable',NULL,NULL,'2026-07-24 07:01:17','2026-07-24 08:02:23','TCL',NULL,NULL);
INSERT INTO "equipment_items" ("id","branch_id","asset_number","name","category","vendor","price","purchase_date","warranty_expiry","status","notes","created_by","created_at","updated_at","brand_model","purchase_source","issue_note") VALUES('0a235c37-dc7a-4af0-bad1-65fe01beba8f','mrm1sbqy8v3zb','FZ-01-001','ตู้เย็น','เครื่องใช้ไฟฟ้า','Homepro',13000,'2024-03-24',NULL,'usable',NULL,NULL,'2026-07-24 07:02:22','2026-07-24 08:02:15','LG',NULL,NULL);
INSERT INTO "equipment_items" ("id","branch_id","asset_number","name","category","vendor","price","purchase_date","warranty_expiry","status","notes","created_by","created_at","updated_at","brand_model","purchase_source","issue_note") VALUES('c5d602e8-e535-4494-9fc0-2916f495c714','mrm1sbqy8v3zb','A-01-001','แอร์','เครื่องใช้ไฟฟ้า','Homepro',60000,'2024-03-24',NULL,'usable',NULL,NULL,'2026-07-24 08:04:05','2026-07-24 08:04:05','Carrier/40000BTU',NULL,NULL);
CREATE TABLE mar_slot_settings (
  branch_id TEXT NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  slot_key TEXT NOT NULL CHECK (slot_key IN ('morning','noon','evening','night')),
  time_value TEXT NOT NULL,
  PRIMARY KEY (branch_id, slot_key)
);
CREATE INDEX idx_users_branch   ON users(branch_id);
CREATE INDEX idx_branches_org   ON branches(org_id);
CREATE INDEX idx_cases_branch   ON cases(branch_id);
CREATE INDEX idx_entries_case   ON entries(case_id, ym);
CREATE INDEX idx_payments_case  ON payments(case_id, ym);
CREATE INDEX idx_bank_accounts_branch ON bank_accounts(branch_id);
CREATE INDEX idx_adhoc_bills_case ON adhoc_bills(case_id);
CREATE INDEX idx_adhoc_bill_items_bill ON adhoc_bill_items(bill_id);
CREATE INDEX idx_user_branch_access_user   ON user_branch_access(user_id);
CREATE INDEX idx_user_branch_access_branch ON user_branch_access(branch_id);
CREATE INDEX idx_appointments_case ON appointments(case_id);
CREATE INDEX idx_appointments_date ON appointments(date);
CREATE INDEX idx_items_branch ON medication_items(branch_id);
CREATE INDEX idx_schedule_case ON medication_schedules(case_id, is_active);
CREATE INDEX idx_items_case ON medication_items(case_id);
CREATE INDEX idx_push_subs_branch ON push_subscriptions(branch_id);
CREATE INDEX idx_ms_staff_branch ON ms_staff_accounts(branch_id);
CREATE INDEX idx_stock_tx_item ON stock_transactions(item_id);
CREATE INDEX idx_stock_tx_case ON stock_transactions(case_id);
CREATE INDEX idx_stock_tx_expiry ON stock_transactions(expiry_date);
CREATE INDEX idx_mar_case_time ON medication_admin_logs(case_id, scheduled_time);
CREATE INDEX idx_mar_status ON medication_admin_logs(status);
CREATE INDEX idx_vitals_case_time ON vital_signs(case_id, recorded_at);
CREATE INDEX idx_equipment_branch ON equipment_items(branch_id);
CREATE INDEX idx_equipment_status ON equipment_items(status);
CREATE INDEX idx_equipment_category ON equipment_items(category);
