PRAGMA defer_foreign_keys=TRUE;
CREATE TABLE orgs (
  id    TEXT PRIMARY KEY,
  name  TEXT NOT NULL,
  logo  TEXT,
  staff TEXT,
  note  TEXT
, logo_key TEXT, company_name TEXT NOT NULL DEFAULT '', tax_id TEXT NOT NULL DEFAULT '', address TEXT NOT NULL DEFAULT '');
INSERT INTO "orgs" ("id","name","logo","staff","note","logo_key","company_name","tax_id","address") VALUES('mrm0mwlsmit8z','ศูนย์ดูแลผู้สูงอายุ มาสุเนอร์สซิ่งโฮม','MASU','','','org-mrm0mwlsmit8z-1784189982439.jpeg','บริษัท 2 อันดาเวลเนส จำกัด','0105568175186','768/93 ซอยพัฒนาการ38 ถนนพัฒนาการ แขวงสวนหลวง เขตสวนหลวง กรุงเทพมหานคร');
INSERT INTO "orgs" ("id","name","logo","staff","note","logo_key","company_name","tax_id","address") VALUES('mrm1tvnrhvvh6','ศูนย์ดูแลผู้สูงอายุ จามจุรี เนอร์สซิ่งโฮม','จามจุรี','ผิงอัน','หากชำระเงินสด มีส่วนลด 300 บาท','','','','');
CREATE TABLE branches (
  id      TEXT PRIMARY KEY,
  org_id  TEXT NOT NULL REFERENCES orgs(id) ON DELETE CASCADE,
  name    TEXT NOT NULL,
  address TEXT,
  phone   TEXT
, code TEXT, staff TEXT DEFAULT '', signature_key TEXT DEFAULT '');
INSERT INTO "branches" ("id","org_id","name","address","phone","code","staff","signature_key") VALUES('mrm0nhoxgn7rg','mrm0mwlsmit8z','งามวงศ์วาน','173/1 ซ.งามวงศ์วาน 30 ถ.งามวงศ์วาน ทุ่งสองห้อง หลักสี่ กรุงเทพฯ 10210','091-299-1644 , 065-417-9444','M02','เมย์','');
INSERT INTO "branches" ("id","org_id","name","address","phone","code","staff","signature_key") VALUES('mrm1sbqy8v3zb','mrm0mwlsmit8z','ประชาชื่น','72 ซ.งามวงศ์วาน 31 แยก 16 ถ.งามวงศ์วาน ต.บางเขน อ.เมืองนนทบุรี จ.นนทบุรี 11000','091-299-1644 , 093-564-4742','M01','นางสาวเอ','');
INSERT INTO "branches" ("id","org_id","name","address","phone","code","staff","signature_key") VALUES('mrm1vq2rwh9kf','mrm1tvnrhvvh6','รัชโยธิน','456 ซ.พหลโยธิน 35 แยก 5-2-3 ลาดยาว จตุจักร กรุงเทพฯ 10900','091-599-6662','J01','','');
INSERT INTO "branches" ("id","org_id","name","address","phone","code","staff","signature_key") VALUES('mrn732ey93cog','mrm1tvnrhvvh6','ลาดพร้าว 38','888 ซ.ลาดพร้าว 38 ถ.ลาดพร้าว ........','099-999-9911','J02','','');
INSERT INTO "branches" ("id","org_id","name","address","phone","code","staff","signature_key") VALUES('mrn74e5733z9c','mrm1tvnrhvvh6','บางเขน','88 ซ.พหลโยธิน 63 ถ.พหลโยธิน อนุสาวรีย์ บางเขน กรุงเทพฯ','091-191-9111','J03','','');
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
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrqktstrz1849','mrm0nhoxgn7rg','111','',23000,17,'ธนาคารกสิกรไทย','212-8-85185-5','บำเพ็ญ ไชยอุดม',NULL,'','','','','2026-07-17','','mrpx358n1sd2y',0,NULL,'','','','','');
INSERT INTO "cases" ("id","branch_id","name","note","monthly_fee","due_day","bank_name","bank_acc","bank_owner","age","health_info","allergy","emergency_contact","emergency_phone","admission_date","photo_key","bank_account_id","moved_out","move_out_date","due_date_override","withholding_override","address","phone","tax_id") VALUES('mrwyazghw25sk','mrm1sbqy8v3zb','คุณตาทดสอบ','',23000,23,'กสิกรไทย','221-8-34321-2','บริษัท 2 อันดาเวลเนส จำกัด',NULL,'','','','','2026-07-23','','mrx0cqwgbn9kc',0,NULL,'2026-07-23','always','-','099-125-1251','0000000000009');
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
INSERT INTO "doc_sequences" ("branch_id","doc_type","year","bank_account_id","last_seq") VALUES('mrm1sbqy8v3zb','invoice',2569,'',8);
INSERT INTO "doc_sequences" ("branch_id","doc_type","year","bank_account_id","last_seq") VALUES('mrm0nhoxgn7rg','invoice',2569,'',2);
INSERT INTO "doc_sequences" ("branch_id","doc_type","year","bank_account_id","last_seq") VALUES('mrm1sbqy8v3zb','receipt',2569,'',9);
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
CREATE TABLE stock_transactions (
  id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL REFERENCES medication_items(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('receive','dispense','adjust')),
  quantity REAL NOT NULL,             -- เก็บเป็นค่าบวกเสมอ ทิศทางดูจาก type
  lot_no TEXT,
  expiry_date TEXT,                   -- YYYY-MM-DD
  case_id TEXT REFERENCES cases(id) ON DELETE SET NULL,
  reference_note TEXT,
  performed_by TEXT REFERENCES users(id),
  created_at TEXT DEFAULT (datetime('now'))
, voided INTEGER NOT NULL DEFAULT 0, void_reason TEXT);
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
);
CREATE TABLE medication_admin_logs (
  id TEXT PRIMARY KEY,
  schedule_id TEXT NOT NULL REFERENCES medication_schedules(id) ON DELETE CASCADE,
  case_id TEXT NOT NULL REFERENCES cases(id) ON DELETE CASCADE,
  item_id TEXT NOT NULL REFERENCES medication_items(id),
  scheduled_time TEXT NOT NULL,       -- เวลาที่ควรให้ (datetime แบบ 'YYYY-MM-DD HH:MM')
  actual_time TEXT,                   -- เวลาที่ให้จริง (NULL = ยังไม่ให้)
  status TEXT NOT NULL DEFAULT 'pending'
         CHECK (status IN ('pending','given','missed','refused','held')),
  given_by TEXT REFERENCES users(id),
  notes TEXT,
  created_at TEXT DEFAULT (datetime('now'))
, stock_transaction_id TEXT REFERENCES stock_transactions(id));
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
  recorded_by TEXT REFERENCES users(id),
  created_at TEXT DEFAULT (datetime('now'))
);
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
INSERT INTO "ms_staff_accounts" ("id","username","password_hash","password_salt","display_name","role","branch_id","is_active","created_at") VALUES('5cf93acc-a0d2-4984-8d86-466a4e7f5660','Masu01','PXCKBXTBWgPKZADo9cjdN_oOn6Bn7GNi3Xo-Hz-88CA','cRG4N5DE0t1q24ys2wXNpw','มาสุ01','staff',NULL,1,'2026-07-22 08:57:01');
INSERT INTO "ms_staff_accounts" ("id","username","password_hash","password_salt","display_name","role","branch_id","is_active","created_at") VALUES('98284a53-6360-4186-92f6-8160d62a5bcd','Masu02','VRTUUOWgLpQbq-kudJgwXciy0r53zC4sgYkMRijVYdc','qlsmI3QO3h1GnEo8vnALmQ','มาสุ02','staff',NULL,1,'2026-07-22 08:57:21');
INSERT INTO "ms_staff_accounts" ("id","username","password_hash","password_salt","display_name","role","branch_id","is_active","created_at") VALUES('1ed2abd7-746d-4290-af2b-bd003cabc1ae','pla','QXtck9Yw0YSj_FzqU_NOyKOhAkgGi5z4Xp8k3gScIns','Iw4sJ8T2geMO7Q2ABpAbTg','ปลา','manager',NULL,1,'2026-07-22 08:58:01');
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
CREATE INDEX idx_stock_tx_item ON stock_transactions(item_id);
CREATE INDEX idx_stock_tx_case ON stock_transactions(case_id);
CREATE INDEX idx_stock_tx_expiry ON stock_transactions(expiry_date);
CREATE INDEX idx_schedule_case ON medication_schedules(case_id, is_active);
CREATE INDEX idx_mar_case_time ON medication_admin_logs(case_id, scheduled_time);
CREATE INDEX idx_mar_status ON medication_admin_logs(status);
CREATE INDEX idx_vitals_case_time ON vital_signs(case_id, recorded_at);
CREATE INDEX idx_items_case ON medication_items(case_id);
CREATE INDEX idx_push_subs_branch ON push_subscriptions(branch_id);
CREATE INDEX idx_ms_staff_branch ON ms_staff_accounts(branch_id);
