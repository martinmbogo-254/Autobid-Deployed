BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "auth_group" (
	"id"	integer NOT NULL,
	"name"	varchar(150) NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_group_permissions" (
	"id"	integer NOT NULL,
	"group_id"	integer NOT NULL,
	"permission_id"	integer NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("group_id") REFERENCES "auth_group"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("permission_id") REFERENCES "auth_permission"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "auth_permission" (
	"id"	integer NOT NULL,
	"content_type_id"	integer NOT NULL,
	"codename"	varchar(100) NOT NULL,
	"name"	varchar(255) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("content_type_id") REFERENCES "django_content_type"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "auth_user" (
	"id"	integer NOT NULL,
	"password"	varchar(128) NOT NULL,
	"last_login"	datetime,
	"is_superuser"	bool NOT NULL,
	"username"	varchar(150) NOT NULL UNIQUE,
	"last_name"	varchar(150) NOT NULL,
	"email"	varchar(254) NOT NULL,
	"is_staff"	bool NOT NULL,
	"is_active"	bool NOT NULL,
	"date_joined"	datetime NOT NULL,
	"first_name"	varchar(150) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "auth_user_groups" (
	"id"	integer NOT NULL,
	"user_id"	integer NOT NULL,
	"group_id"	integer NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("group_id") REFERENCES "auth_group"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "auth_user_user_permissions" (
	"id"	integer NOT NULL,
	"user_id"	integer NOT NULL,
	"permission_id"	integer NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("permission_id") REFERENCES "auth_permission"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "django_admin_log" (
	"id"	integer NOT NULL,
	"object_id"	text,
	"object_repr"	varchar(200) NOT NULL,
	"action_flag"	smallint unsigned NOT NULL CHECK("action_flag" >= 0),
	"change_message"	text NOT NULL,
	"content_type_id"	integer,
	"user_id"	integer NOT NULL,
	"action_time"	datetime NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("content_type_id") REFERENCES "django_content_type"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "django_content_type" (
	"id"	integer NOT NULL,
	"app_label"	varchar(100) NOT NULL,
	"model"	varchar(100) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "django_migrations" (
	"id"	integer NOT NULL,
	"app"	varchar(255) NOT NULL,
	"name"	varchar(255) NOT NULL,
	"applied"	datetime NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "django_session" (
	"session_key"	varchar(40) NOT NULL,
	"session_data"	text NOT NULL,
	"expire_date"	datetime NOT NULL,
	PRIMARY KEY("session_key")
);
CREATE TABLE IF NOT EXISTS "users_location" (
	"id"	integer NOT NULL,
	"city"	varchar(100) NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "users_profile" (
	"id"	integer NOT NULL,
	"user_id"	integer NOT NULL UNIQUE,
	"ID_number"	integer UNIQUE,
	"phone_number"	integer UNIQUE,
	"location_id"	bigint,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("location_id") REFERENCES "users_location"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "vehicles_auction" (
	"id"	integer NOT NULL,
	"auction_id"	char(32) NOT NULL UNIQUE,
	"start_date"	datetime NOT NULL,
	"end_date"	datetime NOT NULL,
	"approved"	bool NOT NULL,
	"created_at"	datetime NOT NULL,
	"approved_at"	datetime,
	"approved_by_id"	integer,
	"has_extended"	bool NOT NULL,
	"processed"	bool NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("approved_by_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "vehicles_auction_vehicles" (
	"id"	integer NOT NULL,
	"auction_id"	bigint NOT NULL,
	"vehicle_id"	bigint NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("auction_id") REFERENCES "vehicles_auction"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("vehicle_id") REFERENCES "vehicles_vehicle"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "vehicles_auctionhistory" (
	"id"	integer NOT NULL,
	"start_date"	datetime NOT NULL,
	"end_date"	datetime NOT NULL,
	"auction_id"	bigint NOT NULL,
	"vehicle_id"	bigint NOT NULL,
	"returned_to_available"	bool NOT NULL,
	"on_bid"	bool NOT NULL,
	"sold"	bool NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("auction_id") REFERENCES "vehicles_auction"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("vehicle_id") REFERENCES "vehicles_vehicle"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "vehicles_bidding" (
	"id"	integer NOT NULL,
	"amount"	integer NOT NULL,
	"bid_time"	datetime NOT NULL,
	"vehicle_id"	bigint NOT NULL,
	"user_id"	integer NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("vehicle_id") REFERENCES "vehicles_vehicle"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "vehicles_financier" (
	"id"	integer NOT NULL,
	"name"	varchar(255) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "vehicles_fueltype" (
	"id"	integer NOT NULL,
	"name"	varchar(255) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "vehicles_manufactureyear" (
	"id"	integer NOT NULL,
	"year"	integer NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "vehicles_notificationrecipient" (
	"id"	integer NOT NULL,
	"email"	varchar(254) NOT NULL,
	"name"	varchar(100) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "vehicles_vehicle" (
	"id"	integer NOT NULL,
	"mileage"	integer,
	"created_at"	datetime NOT NULL,
	"updated_at"	datetime NOT NULL,
	"engine_cc"	integer NOT NULL,
	"reserve_price"	integer NOT NULL,
	"YOM_id"	bigint NOT NULL,
	"fuel_type_id"	bigint NOT NULL,
	"body_type_id"	bigint NOT NULL,
	"make_id"	bigint NOT NULL,
	"model_id"	bigint NOT NULL,
	"file"	varchar(100) NOT NULL,
	"views"	integer NOT NULL,
	"registration_no"	varchar(255) NOT NULL UNIQUE,
	"v_id"	char(32) NOT NULL UNIQUE,
	"status"	varchar(10) NOT NULL,
	"transmission"	varchar(255) NOT NULL,
	"description"	text NOT NULL,
	"color"	varchar(10) NOT NULL,
	"seats"	integer NOT NULL,
	"Financier_id"	bigint,
	"yard_id"	bigint,
	"approved_at"	datetime,
	"approved_by_id"	integer,
	"is_approved"	bool NOT NULL,
	"is_hotsale"	bool NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("Financier_id") REFERENCES "vehicles_financier"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("YOM_id") REFERENCES "vehicles_manufactureyear"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("approved_by_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("body_type_id") REFERENCES "vehicles_vehiclebody"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("fuel_type_id") REFERENCES "vehicles_fueltype"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("make_id") REFERENCES "vehicles_vehiclemake"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("model_id") REFERENCES "vehicles_vehiclemodel"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("yard_id") REFERENCES "vehicles_yard"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "vehicles_vehiclebody" (
	"id"	integer NOT NULL,
	"name"	varchar(255) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "vehicles_vehicleimage" (
	"id"	integer NOT NULL,
	"vehicle_id"	bigint NOT NULL,
	"image"	varchar(100) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("vehicle_id") REFERENCES "vehicles_vehicle"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "vehicles_vehiclemake" (
	"id"	integer NOT NULL,
	"name"	varchar(255) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "vehicles_vehiclemodel" (
	"id"	integer NOT NULL,
	"name"	varchar(255) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "vehicles_vehicleview" (
	"id"	integer NOT NULL,
	"viewed_at"	datetime NOT NULL,
	"user_id"	integer NOT NULL,
	"vehicle_id"	bigint NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "auth_user"("id") DEFERRABLE INITIALLY DEFERRED,
	FOREIGN KEY("vehicle_id") REFERENCES "vehicles_vehicle"("id") DEFERRABLE INITIALLY DEFERRED
);
CREATE TABLE IF NOT EXISTS "vehicles_yard" (
	"id"	integer NOT NULL,
	"name"	varchar(255) NOT NULL,
	"link"	varchar(255) NOT NULL,
	PRIMARY KEY("id" AUTOINCREMENT)
);
INSERT INTO "auth_group" VALUES (1,'Staff');
INSERT INTO "auth_group" VALUES (2,'Admins');
INSERT INTO "auth_group" VALUES (3,'Financiers');
INSERT INTO "auth_group" VALUES (4,'Sales');
INSERT INTO "auth_group_permissions" VALUES (1,4,33);
INSERT INTO "auth_group_permissions" VALUES (2,4,34);
INSERT INTO "auth_group_permissions" VALUES (3,4,36);
INSERT INTO "auth_group_permissions" VALUES (4,4,37);
INSERT INTO "auth_group_permissions" VALUES (5,4,38);
INSERT INTO "auth_group_permissions" VALUES (6,4,40);
INSERT INTO "auth_group_permissions" VALUES (7,4,41);
INSERT INTO "auth_group_permissions" VALUES (8,4,42);
INSERT INTO "auth_group_permissions" VALUES (9,4,44);
INSERT INTO "auth_group_permissions" VALUES (10,4,45);
INSERT INTO "auth_group_permissions" VALUES (11,4,46);
INSERT INTO "auth_group_permissions" VALUES (12,4,48);
INSERT INTO "auth_group_permissions" VALUES (13,4,49);
INSERT INTO "auth_group_permissions" VALUES (14,4,50);
INSERT INTO "auth_group_permissions" VALUES (15,4,52);
INSERT INTO "auth_group_permissions" VALUES (16,4,85);
INSERT INTO "auth_group_permissions" VALUES (17,4,86);
INSERT INTO "auth_group_permissions" VALUES (18,4,88);
INSERT INTO "auth_permission" VALUES (1,1,'add_logentry','Can add log entry');
INSERT INTO "auth_permission" VALUES (2,1,'change_logentry','Can change log entry');
INSERT INTO "auth_permission" VALUES (3,1,'delete_logentry','Can delete log entry');
INSERT INTO "auth_permission" VALUES (4,1,'view_logentry','Can view log entry');
INSERT INTO "auth_permission" VALUES (5,2,'add_permission','Can add permission');
INSERT INTO "auth_permission" VALUES (6,2,'change_permission','Can change permission');
INSERT INTO "auth_permission" VALUES (7,2,'delete_permission','Can delete permission');
INSERT INTO "auth_permission" VALUES (8,2,'view_permission','Can view permission');
INSERT INTO "auth_permission" VALUES (9,3,'add_group','Can add group');
INSERT INTO "auth_permission" VALUES (10,3,'change_group','Can change group');
INSERT INTO "auth_permission" VALUES (11,3,'delete_group','Can delete group');
INSERT INTO "auth_permission" VALUES (12,3,'view_group','Can view group');
INSERT INTO "auth_permission" VALUES (13,4,'add_user','Can add user');
INSERT INTO "auth_permission" VALUES (14,4,'change_user','Can change user');
INSERT INTO "auth_permission" VALUES (15,4,'delete_user','Can delete user');
INSERT INTO "auth_permission" VALUES (16,4,'view_user','Can view user');
INSERT INTO "auth_permission" VALUES (17,5,'add_contenttype','Can add content type');
INSERT INTO "auth_permission" VALUES (18,5,'change_contenttype','Can change content type');
INSERT INTO "auth_permission" VALUES (19,5,'delete_contenttype','Can delete content type');
INSERT INTO "auth_permission" VALUES (20,5,'view_contenttype','Can view content type');
INSERT INTO "auth_permission" VALUES (21,6,'add_session','Can add session');
INSERT INTO "auth_permission" VALUES (22,6,'change_session','Can change session');
INSERT INTO "auth_permission" VALUES (23,6,'delete_session','Can delete session');
INSERT INTO "auth_permission" VALUES (24,6,'view_session','Can view session');
INSERT INTO "auth_permission" VALUES (25,7,'add_fueltype','Can add fuel type');
INSERT INTO "auth_permission" VALUES (26,7,'change_fueltype','Can change fuel type');
INSERT INTO "auth_permission" VALUES (27,7,'delete_fueltype','Can delete fuel type');
INSERT INTO "auth_permission" VALUES (28,7,'view_fueltype','Can view fuel type');
INSERT INTO "auth_permission" VALUES (29,8,'add_manufactureyear','Can add manufacture year');
INSERT INTO "auth_permission" VALUES (30,8,'change_manufactureyear','Can change manufacture year');
INSERT INTO "auth_permission" VALUES (31,8,'delete_manufactureyear','Can delete manufacture year');
INSERT INTO "auth_permission" VALUES (32,8,'view_manufactureyear','Can view manufacture year');
INSERT INTO "auth_permission" VALUES (33,9,'add_vehiclebody','Can add vehicle body');
INSERT INTO "auth_permission" VALUES (34,9,'change_vehiclebody','Can change vehicle body');
INSERT INTO "auth_permission" VALUES (35,9,'delete_vehiclebody','Can delete vehicle body');
INSERT INTO "auth_permission" VALUES (36,9,'view_vehiclebody','Can view vehicle body');
INSERT INTO "auth_permission" VALUES (37,10,'add_vehicleimage','Can add vehicle image');
INSERT INTO "auth_permission" VALUES (38,10,'change_vehicleimage','Can change vehicle image');
INSERT INTO "auth_permission" VALUES (39,10,'delete_vehicleimage','Can delete vehicle image');
INSERT INTO "auth_permission" VALUES (40,10,'view_vehicleimage','Can view vehicle image');
INSERT INTO "auth_permission" VALUES (41,11,'add_vehiclemake','Can add vehicle make');
INSERT INTO "auth_permission" VALUES (42,11,'change_vehiclemake','Can change vehicle make');
INSERT INTO "auth_permission" VALUES (43,11,'delete_vehiclemake','Can delete vehicle make');
INSERT INTO "auth_permission" VALUES (44,11,'view_vehiclemake','Can view vehicle make');
INSERT INTO "auth_permission" VALUES (45,12,'add_vehiclemodel','Can add vehicle model');
INSERT INTO "auth_permission" VALUES (46,12,'change_vehiclemodel','Can change vehicle model');
INSERT INTO "auth_permission" VALUES (47,12,'delete_vehiclemodel','Can delete vehicle model');
INSERT INTO "auth_permission" VALUES (48,12,'view_vehiclemodel','Can view vehicle model');
INSERT INTO "auth_permission" VALUES (49,13,'add_vehicle','Can add vehicle');
INSERT INTO "auth_permission" VALUES (50,13,'change_vehicle','Can change vehicle');
INSERT INTO "auth_permission" VALUES (51,13,'delete_vehicle','Can delete vehicle');
INSERT INTO "auth_permission" VALUES (52,13,'view_vehicle','Can view vehicle');
INSERT INTO "auth_permission" VALUES (53,14,'add_bidding','Can add bidding');
INSERT INTO "auth_permission" VALUES (54,14,'change_bidding','Can change bidding');
INSERT INTO "auth_permission" VALUES (55,14,'delete_bidding','Can delete bidding');
INSERT INTO "auth_permission" VALUES (56,14,'view_bidding','Can view bidding');
INSERT INTO "auth_permission" VALUES (57,15,'add_auction','Can add auction');
INSERT INTO "auth_permission" VALUES (58,15,'change_auction','Can change auction');
INSERT INTO "auth_permission" VALUES (59,15,'delete_auction','Can delete auction');
INSERT INTO "auth_permission" VALUES (60,15,'view_auction','Can view auction');
INSERT INTO "auth_permission" VALUES (61,16,'add_vehicleview','Can add vehicle view');
INSERT INTO "auth_permission" VALUES (62,16,'change_vehicleview','Can change vehicle view');
INSERT INTO "auth_permission" VALUES (63,16,'delete_vehicleview','Can delete vehicle view');
INSERT INTO "auth_permission" VALUES (64,16,'view_vehicleview','Can view vehicle view');
INSERT INTO "auth_permission" VALUES (65,17,'add_profile','Can add profile');
INSERT INTO "auth_permission" VALUES (66,17,'change_profile','Can change profile');
INSERT INTO "auth_permission" VALUES (67,17,'delete_profile','Can delete profile');
INSERT INTO "auth_permission" VALUES (68,17,'view_profile','Can view profile');
INSERT INTO "auth_permission" VALUES (69,18,'add_auctionhistory','Can add auction history');
INSERT INTO "auth_permission" VALUES (70,18,'change_auctionhistory','Can change auction history');
INSERT INTO "auth_permission" VALUES (71,18,'delete_auctionhistory','Can delete auction history');
INSERT INTO "auth_permission" VALUES (72,18,'view_auctionhistory','Can view auction history');
INSERT INTO "auth_permission" VALUES (73,19,'add_location','Can add location');
INSERT INTO "auth_permission" VALUES (74,19,'change_location','Can change location');
INSERT INTO "auth_permission" VALUES (75,19,'delete_location','Can delete location');
INSERT INTO "auth_permission" VALUES (76,19,'view_location','Can view location');
INSERT INTO "auth_permission" VALUES (77,20,'add_notificationrecipient','Can add notification recipient');
INSERT INTO "auth_permission" VALUES (78,20,'change_notificationrecipient','Can change notification recipient');
INSERT INTO "auth_permission" VALUES (79,20,'delete_notificationrecipient','Can delete notification recipient');
INSERT INTO "auth_permission" VALUES (80,20,'view_notificationrecipient','Can view notification recipient');
INSERT INTO "auth_permission" VALUES (81,21,'add_financier','Can add financier');
INSERT INTO "auth_permission" VALUES (82,21,'change_financier','Can change financier');
INSERT INTO "auth_permission" VALUES (83,21,'delete_financier','Can delete financier');
INSERT INTO "auth_permission" VALUES (84,21,'view_financier','Can view financier');
INSERT INTO "auth_permission" VALUES (85,22,'add_yard','Can add yard');
INSERT INTO "auth_permission" VALUES (86,22,'change_yard','Can change yard');
INSERT INTO "auth_permission" VALUES (87,22,'delete_yard','Can delete yard');
INSERT INTO "auth_permission" VALUES (88,22,'view_yard','Can view yard');
INSERT INTO "auth_user" VALUES (1,'pbkdf2_sha256$720000$EymE64xSUZVWQctcRNg9Sn$+8NHQj627ADnXmAsaqa3EvGxaDMtHRPv1W0ljC6F5V0=','2025-01-15 10:08:01.578682',1,'mbogo','','mbogomartin25@gmail.com',1,1,'2024-07-28 05:20:45','');
INSERT INTO "auth_user" VALUES (9,'pbkdf2_sha256$720000$6Gziyn9ttVwrSNy6EGnm0D$BI5HNf8gbj5INYq52wfttorpEGNVigTceFfn7HR+g6U=','2025-01-03 13:42:03.664857',0,'janedoe','','mburum332@gmail.com',1,1,'2024-08-28 15:57:41','');
INSERT INTO "auth_user" VALUES (13,'pbkdf2_sha256$720000$avmiMqHIZwIGP6Q69P1NAm$FfeR7k6byp5HP9JwTBFPY+908gJsAzLr/dbBFaOgMJE=','2024-11-18 06:31:51.603770',1,'agango','Odhiambo','walteragango@gmail.com',1,1,'2024-11-18 04:38:35','Walter');
INSERT INTO "auth_user" VALUES (14,'pbkdf2_sha256$720000$UMZwuZzomRAZ6yNRudRagZ$lQQUb/aHRMrYIZy5Oqq66OHGd5CRRFykoPHEhnUO0SA=','2025-01-10 14:18:01.786688',1,'walter','Odhiambo','wodhiambo@riverlong.com',1,1,'2025-01-03 11:46:25','Walter');
INSERT INTO "auth_user" VALUES (15,'pbkdf2_sha256$720000$QG5S8DPairXt5yFXG9BOEd$YDyueyWcKAyl9ylrppX4kDoqebbbWXvPEdXFZuiStEw=','2025-01-04 07:23:50',1,'esther','Macharia','emacharia@riverlong.com',1,1,'2025-01-04 07:00:14','Esther');
INSERT INTO "auth_user" VALUES (16,'pbkdf2_sha256$720000$A8U8YMMK7BtzOfwq9hAwtO$Bv74TsoZnX8DTd2wNPq7dOzsR3s91zKxoRQvOK/+kFE=','2025-01-14 14:07:01.055516',1,'Alex','Miller','alexmillera22@gmail.com',1,1,'2025-01-09 08:42:35','Alex');
INSERT INTO "auth_user" VALUES (17,'pbkdf2_sha256$720000$VFUfMoAkMrcDpld7k9B18R$KsxC3tpNUKw2ic41DT0b3nLaABSHakS32JFx2Dsl8W8=','2025-01-15 07:19:48.611136',1,'Stephen','Githinji','sgithinji@riverlong.com',1,1,'2025-01-09 09:14:37','Stephen');
INSERT INTO "auth_user" VALUES (18,'pbkdf2_sha256$720000$9pDCK93g0qh1Eu4is1rDeV$e6YKO9RhdT4Mx1QkAY97Dsp+eId0GeElf6MqMJQBOII=','2025-01-11 08:35:54.967290',0,'Essy','','wangarimacharia2@gmail.com',0,1,'2025-01-11 08:35:46.859538','');
INSERT INTO "auth_user" VALUES (19,'pbkdf2_sha256$720000$p3UA5fnJCdlj6rnX2XKOfk$SVg20cY+3++R+2zYLyXu9Ba8yMy+PMg0lc0/xKzvP0Y=','2025-01-11 08:38:56.890957',0,'Angela','','akihu@riverlong.com',0,1,'2025-01-11 08:38:26.510562','');
INSERT INTO "auth_user" VALUES (20,'pbkdf2_sha256$720000$qjZfmX1LYqMJBGvm3osVG0$Wcu7QUKjSgmBcopOPBe5Dp7iIqawfybrzuPiEZE1J5o=','2025-01-11 08:45:28.339704',0,'Kage','','dkage@mycredit.co.ke',0,1,'2025-01-11 08:44:50.263179','');
INSERT INTO "auth_user" VALUES (21,'pbkdf2_sha256$720000$oOkpohohi8YtMUP4skOd36$c2tgXBgaMrxgOizcIvo3KbKu7m18pT2KDukQH4mfyGQ=',NULL,0,'Maramaasai','','thamesholidays@gmail.com',0,1,'2025-01-14 08:00:39.468936','');
INSERT INTO "auth_user" VALUES (22,'pbkdf2_sha256$720000$lSiheyaTlq96LFVDUH6A6T$4GNlJYIOPYjhIIOsqK0E457fvGssrFCNinXtUEkquXs=','2025-01-14 08:51:03.565271',0,'Sam','','samdoc2030@gmail.com',0,1,'2025-01-14 08:50:29.877635','');
INSERT INTO "auth_user" VALUES (23,'pbkdf2_sha256$720000$2nTksSefQNqH5rTNG4kOYP$FC6LBssRADFBqxeqjpit746f4qeOy0RKZNLQdrN/yk4=','2025-01-14 09:28:19.913867',0,'Bonface','','bonifacemuthomi2018@gmail.com',0,1,'2025-01-14 09:27:54.539844','');
INSERT INTO "auth_user" VALUES (24,'pbkdf2_sha256$720000$fcFrd4YefNJ1EVV4gom2J2$kjaxjEbJEb23gEPIMV7EDmi8/ocwK7aQb+M9ccdv248=','2025-01-14 09:53:41.351694',0,'Ndungu','','ndungu544c@gmail.com',0,1,'2025-01-14 09:53:19.783619','');
INSERT INTO "auth_user" VALUES (25,'pbkdf2_sha256$720000$nbzQHk37fV4oS3pDuP9FFN$7UAjiWXhRRhnIqzD3lbhloQkzvx2cSAwdMDxZGKrWmw=','2025-01-14 10:25:24.631843',0,'Haron','','mburuharon81@gmail.com',0,1,'2025-01-14 10:25:09.507913','');
INSERT INTO "auth_user" VALUES (26,'pbkdf2_sha256$720000$sHU8zVR1o6RzG2cyBtfzed$VOACG2ClNzcCYevlOYFWDAM2jDKoSHnZJou/7JighO0=','2025-01-15 11:11:17.652914',0,'Muriuki','','dmuriuki057@gmail.com',0,1,'2025-01-14 11:03:25.878353','');
INSERT INTO "auth_user" VALUES (27,'pbkdf2_sha256$720000$H8ygENkGitQNal0U9lxp3R$7D8i1yGiPDY17JiTSQ+hWuonUAysCDiGwXvrr2Z9O7s=','2025-01-14 12:12:27.512195',0,'Edwin','','mugogithinji.ke@gmail.com',0,1,'2025-01-14 12:12:09.753309','');
INSERT INTO "auth_user" VALUES (28,'pbkdf2_sha256$720000$5uV9PmiFvCa6sJErSliSyt$VoI9eESckci5F7uFoSxF0uxAPRKshtCEBJPlUy+aj+s=','2025-01-15 03:52:56.001752',0,'LilianGatwiri','','sweetvalley63@gmail.com',0,1,'2025-01-15 03:52:23.349875','');
INSERT INTO "auth_user" VALUES (29,'pbkdf2_sha256$720000$vbXSvGOfr6ur9HJRoljPiM$E9rG4+6kQCNtH3gzPo93Kx0FBuoSoBpxqLri5L1TFjk=','2025-01-15 05:56:47.704527',0,'Jack','','jackmicharazo102@gmail.com',0,1,'2025-01-15 05:42:58.084251','');
INSERT INTO "auth_user" VALUES (30,'pbkdf2_sha256$720000$bXxCzJ3YGQmVT8tmAdQmFy$fJFrXwPRbWWBReFWaSWcIbpCw9TII87zi4qzr+r8Vm8=','2025-01-15 07:35:34.959536',0,'borismpmc','','borismpmc@gmail.com',0,1,'2025-01-15 07:34:57.731174','');
INSERT INTO "auth_user" VALUES (31,'pbkdf2_sha256$720000$8RAs319qpE2R804ylgk2Hf$h/G/7oDQOnS9leo9LHgJiF+KBsuVMIS/Td+RdKx8vk0=','2025-01-15 07:56:45.543441',0,'Rodah','','rnyabuto@riverlong.com',0,1,'2025-01-15 07:56:21.225858','');
INSERT INTO "auth_user" VALUES (32,'pbkdf2_sha256$720000$lsoPiePLQCWs7HOPUHLnu2$AYC29ero8rbeBQ2LgS/QdInEyTIiA0+oEjzemCs3MN4=',NULL,0,'Joshua','','jmuinde@riverlong.com',0,1,'2025-01-15 08:16:25.511739','');
INSERT INTO "auth_user_groups" VALUES (3,9,4);
INSERT INTO "auth_user_groups" VALUES (6,14,2);
INSERT INTO "auth_user_groups" VALUES (8,1,2);
INSERT INTO "auth_user_groups" VALUES (9,15,2);
INSERT INTO "auth_user_groups" VALUES (10,17,2);
INSERT INTO "auth_user_groups" VALUES (11,16,2);
INSERT INTO "auth_user_user_permissions" VALUES (1,1,1);
INSERT INTO "auth_user_user_permissions" VALUES (2,1,2);
INSERT INTO "auth_user_user_permissions" VALUES (3,1,3);
INSERT INTO "auth_user_user_permissions" VALUES (4,1,4);
INSERT INTO "auth_user_user_permissions" VALUES (5,1,5);
INSERT INTO "auth_user_user_permissions" VALUES (6,1,6);
INSERT INTO "auth_user_user_permissions" VALUES (7,1,7);
INSERT INTO "auth_user_user_permissions" VALUES (8,1,8);
INSERT INTO "auth_user_user_permissions" VALUES (9,1,9);
INSERT INTO "auth_user_user_permissions" VALUES (10,1,10);
INSERT INTO "auth_user_user_permissions" VALUES (11,1,11);
INSERT INTO "auth_user_user_permissions" VALUES (12,1,12);
INSERT INTO "auth_user_user_permissions" VALUES (13,1,13);
INSERT INTO "auth_user_user_permissions" VALUES (14,1,14);
INSERT INTO "auth_user_user_permissions" VALUES (15,1,15);
INSERT INTO "auth_user_user_permissions" VALUES (16,1,16);
INSERT INTO "auth_user_user_permissions" VALUES (17,1,17);
INSERT INTO "auth_user_user_permissions" VALUES (18,1,18);
INSERT INTO "auth_user_user_permissions" VALUES (19,1,19);
INSERT INTO "auth_user_user_permissions" VALUES (20,1,20);
INSERT INTO "auth_user_user_permissions" VALUES (21,1,21);
INSERT INTO "auth_user_user_permissions" VALUES (22,1,22);
INSERT INTO "auth_user_user_permissions" VALUES (23,1,23);
INSERT INTO "auth_user_user_permissions" VALUES (24,1,24);
INSERT INTO "auth_user_user_permissions" VALUES (25,1,25);
INSERT INTO "auth_user_user_permissions" VALUES (26,1,26);
INSERT INTO "auth_user_user_permissions" VALUES (27,1,27);
INSERT INTO "auth_user_user_permissions" VALUES (28,1,28);
INSERT INTO "auth_user_user_permissions" VALUES (29,1,29);
INSERT INTO "auth_user_user_permissions" VALUES (30,1,30);
INSERT INTO "auth_user_user_permissions" VALUES (31,1,31);
INSERT INTO "auth_user_user_permissions" VALUES (32,1,32);
INSERT INTO "auth_user_user_permissions" VALUES (33,1,33);
INSERT INTO "auth_user_user_permissions" VALUES (34,1,34);
INSERT INTO "auth_user_user_permissions" VALUES (35,1,35);
INSERT INTO "auth_user_user_permissions" VALUES (36,1,36);
INSERT INTO "auth_user_user_permissions" VALUES (37,1,37);
INSERT INTO "auth_user_user_permissions" VALUES (38,1,38);
INSERT INTO "auth_user_user_permissions" VALUES (39,1,39);
INSERT INTO "auth_user_user_permissions" VALUES (40,1,40);
INSERT INTO "auth_user_user_permissions" VALUES (41,1,41);
INSERT INTO "auth_user_user_permissions" VALUES (42,1,42);
INSERT INTO "auth_user_user_permissions" VALUES (43,1,43);
INSERT INTO "auth_user_user_permissions" VALUES (44,1,44);
INSERT INTO "auth_user_user_permissions" VALUES (45,1,45);
INSERT INTO "auth_user_user_permissions" VALUES (46,1,46);
INSERT INTO "auth_user_user_permissions" VALUES (47,1,47);
INSERT INTO "auth_user_user_permissions" VALUES (48,1,48);
INSERT INTO "auth_user_user_permissions" VALUES (49,1,49);
INSERT INTO "auth_user_user_permissions" VALUES (50,1,50);
INSERT INTO "auth_user_user_permissions" VALUES (51,1,51);
INSERT INTO "auth_user_user_permissions" VALUES (52,1,52);
INSERT INTO "auth_user_user_permissions" VALUES (53,1,53);
INSERT INTO "auth_user_user_permissions" VALUES (54,1,54);
INSERT INTO "auth_user_user_permissions" VALUES (55,1,55);
INSERT INTO "auth_user_user_permissions" VALUES (56,1,56);
INSERT INTO "auth_user_user_permissions" VALUES (57,1,57);
INSERT INTO "auth_user_user_permissions" VALUES (58,1,58);
INSERT INTO "auth_user_user_permissions" VALUES (59,1,59);
INSERT INTO "auth_user_user_permissions" VALUES (60,1,60);
INSERT INTO "auth_user_user_permissions" VALUES (61,1,61);
INSERT INTO "auth_user_user_permissions" VALUES (62,1,62);
INSERT INTO "auth_user_user_permissions" VALUES (63,1,63);
INSERT INTO "auth_user_user_permissions" VALUES (64,1,64);
INSERT INTO "auth_user_user_permissions" VALUES (65,1,65);
INSERT INTO "auth_user_user_permissions" VALUES (66,1,66);
INSERT INTO "auth_user_user_permissions" VALUES (67,1,67);
INSERT INTO "auth_user_user_permissions" VALUES (68,1,68);
INSERT INTO "auth_user_user_permissions" VALUES (69,1,69);
INSERT INTO "auth_user_user_permissions" VALUES (70,1,70);
INSERT INTO "auth_user_user_permissions" VALUES (71,1,71);
INSERT INTO "auth_user_user_permissions" VALUES (72,1,72);
INSERT INTO "auth_user_user_permissions" VALUES (73,1,73);
INSERT INTO "auth_user_user_permissions" VALUES (74,1,74);
INSERT INTO "auth_user_user_permissions" VALUES (75,1,75);
INSERT INTO "auth_user_user_permissions" VALUES (76,1,76);
INSERT INTO "auth_user_user_permissions" VALUES (77,1,77);
INSERT INTO "auth_user_user_permissions" VALUES (78,1,78);
INSERT INTO "auth_user_user_permissions" VALUES (79,1,79);
INSERT INTO "auth_user_user_permissions" VALUES (80,1,80);
INSERT INTO "auth_user_user_permissions" VALUES (81,1,81);
INSERT INTO "auth_user_user_permissions" VALUES (82,1,82);
INSERT INTO "auth_user_user_permissions" VALUES (83,1,83);
INSERT INTO "auth_user_user_permissions" VALUES (84,1,84);
INSERT INTO "auth_user_user_permissions" VALUES (85,1,85);
INSERT INTO "auth_user_user_permissions" VALUES (86,1,86);
INSERT INTO "auth_user_user_permissions" VALUES (87,1,87);
INSERT INTO "auth_user_user_permissions" VALUES (88,1,88);
INSERT INTO "django_admin_log" VALUES (1,'1','Toyota',1,'[{"added": {}}]',11,1,'2024-07-28 05:29:53.261914');
INSERT INTO "django_admin_log" VALUES (2,'1','Ractis',1,'[{"added": {}}]',12,1,'2024-07-28 05:30:03.534183');
INSERT INTO "django_admin_log" VALUES (3,'1','2015',1,'[{"added": {}}]',8,1,'2024-07-28 05:30:11.186769');
INSERT INTO "django_admin_log" VALUES (4,'1','Hatchback',1,'[{"added": {}}]',9,1,'2024-07-28 05:30:33.972607');
INSERT INTO "django_admin_log" VALUES (5,'1','Petrol',1,'[{"added": {}}]',7,1,'2024-07-28 05:30:42.031780');
INSERT INTO "django_admin_log" VALUES (6,'1','Toyota',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (1)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (2)"}}]',13,1,'2024-07-28 05:33:40.962519');
INSERT INTO "django_admin_log" VALUES (7,'2','Porche',1,'[{"added": {}}]',11,1,'2024-07-28 05:54:17.793857');
INSERT INTO "django_admin_log" VALUES (8,'2','Cayenne',1,'[{"added": {}}]',12,1,'2024-07-28 05:54:28.729392');
INSERT INTO "django_admin_log" VALUES (9,'2','2019',1,'[{"added": {}}]',8,1,'2024-07-28 05:54:36.561472');
INSERT INTO "django_admin_log" VALUES (10,'2','Station Wagon',1,'[{"added": {}}]',9,1,'2024-07-28 05:54:56.936228');
INSERT INTO "django_admin_log" VALUES (11,'2','Diesel',1,'[{"added": {}}]',7,1,'2024-07-28 05:55:06.707382');
INSERT INTO "django_admin_log" VALUES (12,'2','Porche',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (3)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (4)"}}]',13,1,'2024-07-28 05:57:03.650810');
INSERT INTO "django_admin_log" VALUES (13,'2','Porche',2,'[{"added": {"name": "vehicle image", "object": "VehicleImage object (5)"}}]',13,1,'2024-07-28 05:58:35.285180');
INSERT INTO "django_admin_log" VALUES (14,'2','Porche',2,'[{"added": {"name": "vehicle image", "object": "VehicleImage object (6)"}}]',13,1,'2024-07-28 05:58:35.722213');
INSERT INTO "django_admin_log" VALUES (15,'2','Porche',2,'[{"deleted": {"name": "vehicle image", "object": "VehicleImage object (None)"}}]',13,1,'2024-07-28 05:58:55.226759');
INSERT INTO "django_admin_log" VALUES (16,'3','Toyota',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (7)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (8)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (9)"}}]',13,1,'2024-07-28 06:15:24.315122');
INSERT INTO "django_admin_log" VALUES (17,'3','2022',1,'[{"added": {}}]',8,1,'2024-07-29 04:13:44.175314');
INSERT INTO "django_admin_log" VALUES (18,'3','Coupe',1,'[{"added": {}}]',9,1,'2024-07-29 04:13:58.742237');
INSERT INTO "django_admin_log" VALUES (19,'3','Hybrid',1,'[{"added": {}}]',7,1,'2024-07-29 04:14:08.685471');
INSERT INTO "django_admin_log" VALUES (20,'4','Porche',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (10)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (11)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (12)"}}]',13,1,'2024-07-29 04:14:43.188901');
INSERT INTO "django_admin_log" VALUES (21,'1','Auction e61e6331-cfa1-4acc-8b5c-c3cff623310d from 2024-07-30 18:00:00+03:00 to 2024-08-30 15:44:50+03:00',1,'[{"added": {}}]',15,1,'2024-07-29 12:45:01.499645');
INSERT INTO "django_admin_log" VALUES (22,'1','KAA 123A',2,'[{"changed": {"fields": ["Transmission", "Status"]}}]',13,1,'2024-08-08 06:03:25.270442');
INSERT INTO "django_admin_log" VALUES (23,'4','KAA 123T',2,'[{"changed": {"fields": ["Transmission", "Status"]}}]',13,1,'2024-08-08 06:03:34.485868');
INSERT INTO "django_admin_log" VALUES (24,'2','KDQ 001Q',2,'[{"changed": {"fields": ["Transmission", "Fuel type", "Status"]}}]',13,1,'2024-08-08 06:03:57.167390');
INSERT INTO "django_admin_log" VALUES (25,'2','Auction a2e25181-5023-4a8d-b696-606dd710bbd9',1,'[{"added": {}}]',15,1,'2024-08-08 06:04:25.941173');
INSERT INTO "django_admin_log" VALUES (26,'3','KDQ 001W',2,'[{"changed": {"fields": ["Transmission", "Status"]}}]',13,1,'2024-08-08 08:28:28.913569');
INSERT INTO "django_admin_log" VALUES (27,'5','mbogo12',3,'',4,1,'2024-08-08 08:50:11.566167');
INSERT INTO "django_admin_log" VALUES (28,'3','Auction 5452cb3d-c20f-4bfd-a5ed-94249b96713a',1,'[{"added": {}}]',15,1,'2024-08-08 08:59:03.095407');
INSERT INTO "django_admin_log" VALUES (29,'1','Auction e61e6331-cfa1-4acc-8b5c-c3cff623310d',2,'[{"changed": {"fields": ["End date", "Approved"]}}]',15,1,'2024-08-08 10:34:58.655512');
INSERT INTO "django_admin_log" VALUES (30,'1','Auction e61e6331-cfa1-4acc-8b5c-c3cff623310d',3,'',15,1,'2024-08-08 10:35:43.192682');
INSERT INTO "django_admin_log" VALUES (31,'3','Auction 5452cb3d-c20f-4bfd-a5ed-94249b96713a',3,'',15,1,'2024-08-08 10:45:44.824424');
INSERT INTO "django_admin_log" VALUES (32,'2','Auction a2e25181-5023-4a8d-b696-606dd710bbd9',3,'',15,1,'2024-08-08 10:45:44.842569');
INSERT INTO "django_admin_log" VALUES (33,'4','KAA 123T',2,'[{"changed": {"fields": ["Status"]}}]',13,1,'2024-08-08 10:46:21.278744');
INSERT INTO "django_admin_log" VALUES (34,'3','KDQ 001W',2,'[{"changed": {"fields": ["Status"]}}]',13,1,'2024-08-08 10:46:33.383499');
INSERT INTO "django_admin_log" VALUES (35,'2','KDQ 001Q',2,'[{"changed": {"fields": ["Status"]}}]',13,1,'2024-08-08 10:46:44.282808');
INSERT INTO "django_admin_log" VALUES (36,'1','KAA 123A',2,'[{"changed": {"fields": ["Status"]}}]',13,1,'2024-08-08 10:47:02.168584');
INSERT INTO "django_admin_log" VALUES (37,'4','Auction 1f86633a-0148-44ec-b476-0e929632dcea',1,'[{"added": {}}]',15,1,'2024-08-08 10:48:20.867528');
INSERT INTO "django_admin_log" VALUES (38,'4','Auction 1f86633a-0148-44ec-b476-0e929632dcea',3,'',15,1,'2024-08-08 11:06:08.291393');
INSERT INTO "django_admin_log" VALUES (39,'4','KAA 123T',2,'[{"changed": {"fields": ["Status"]}}]',13,1,'2024-08-08 11:06:45.572139');
INSERT INTO "django_admin_log" VALUES (40,'3','KDQ 001W',2,'[{"changed": {"fields": ["Status"]}}]',13,1,'2024-08-08 11:06:56.636385');
INSERT INTO "django_admin_log" VALUES (41,'2','KDQ 001Q',2,'[{"changed": {"fields": ["Status"]}}]',13,1,'2024-08-08 11:07:04.451395');
INSERT INTO "django_admin_log" VALUES (42,'1','KAA 123A',2,'[{"changed": {"fields": ["Status"]}}]',13,1,'2024-08-08 11:07:12.886007');
INSERT INTO "django_admin_log" VALUES (43,'5','Auction fe13de79-5c61-4c1d-8160-9fb56edf4d09',1,'[{"added": {}}]',15,1,'2024-08-08 11:07:41.420304');
INSERT INTO "django_admin_log" VALUES (44,'6','Auction 64aa8b08-97ee-4034-b54a-20e6ce0e08c0',1,'[{"added": {}}]',15,1,'2024-08-08 11:15:03.913775');
INSERT INTO "django_admin_log" VALUES (45,'13','Bidding object (13)',3,'',14,1,'2024-08-08 11:16:22.170901');
INSERT INTO "django_admin_log" VALUES (46,'12','Bidding object (12)',3,'',14,1,'2024-08-08 11:16:22.180339');
INSERT INTO "django_admin_log" VALUES (47,'11','Bidding object (11)',3,'',14,1,'2024-08-08 11:16:22.187124');
INSERT INTO "django_admin_log" VALUES (48,'10','Bidding object (10)',3,'',14,1,'2024-08-08 11:16:22.193520');
INSERT INTO "django_admin_log" VALUES (49,'9','Bidding object (9)',3,'',14,1,'2024-08-08 11:16:22.199976');
INSERT INTO "django_admin_log" VALUES (50,'8','Bidding object (8)',3,'',14,1,'2024-08-08 11:16:22.205610');
INSERT INTO "django_admin_log" VALUES (51,'7','Bidding object (7)',3,'',14,1,'2024-08-08 11:16:22.210569');
INSERT INTO "django_admin_log" VALUES (52,'6','Bidding object (6)',3,'',14,1,'2024-08-08 11:16:22.216765');
INSERT INTO "django_admin_log" VALUES (53,'5','Bidding object (5)',3,'',14,1,'2024-08-08 11:16:22.222272');
INSERT INTO "django_admin_log" VALUES (54,'4','Bidding object (4)',3,'',14,1,'2024-08-08 11:16:22.227153');
INSERT INTO "django_admin_log" VALUES (55,'3','Bidding object (3)',3,'',14,1,'2024-08-08 11:16:22.233663');
INSERT INTO "django_admin_log" VALUES (56,'2','Bidding object (2)',3,'',14,1,'2024-08-08 11:16:22.238687');
INSERT INTO "django_admin_log" VALUES (57,'1','Bidding object (1)',3,'',14,1,'2024-08-08 11:16:22.244047');
INSERT INTO "django_admin_log" VALUES (58,'7','Auction b510f98d-9e60-4377-8e5b-a966d6480e46',1,'[{"added": {}}]',15,1,'2024-08-10 06:16:57.720056');
INSERT INTO "django_admin_log" VALUES (59,'4','KAA 123T',2,'[{"changed": {"fields": ["Status"]}}]',13,1,'2024-08-10 06:31:47.974811');
INSERT INTO "django_admin_log" VALUES (60,'3','KDQ 001W',2,'[{"changed": {"fields": ["Status"]}}]',13,1,'2024-08-10 06:31:56.649820');
INSERT INTO "django_admin_log" VALUES (61,'2','KDQ 001Q',2,'[]',13,1,'2024-08-10 06:32:04.226193');
INSERT INTO "django_admin_log" VALUES (62,'1','KAA 123A',2,'[{"changed": {"fields": ["Status"]}}]',13,1,'2024-08-10 06:32:25.600753');
INSERT INTO "django_admin_log" VALUES (63,'8','Auction 679e68e3-6a2a-4ba6-83e2-45aa5f0bb393',1,'[{"added": {}}]',15,1,'2024-08-10 06:35:16.729846');
INSERT INTO "django_admin_log" VALUES (64,'9','Auction 698295a2-8fb5-4f85-b07f-62911c37ceef',1,'[{"added": {}}]',15,1,'2024-08-10 07:29:02.848578');
INSERT INTO "django_admin_log" VALUES (65,'10','Auction 1f88d4d7-1552-4ca1-8ec8-9493dca8ce28',1,'[{"added": {}}]',15,1,'2024-08-10 09:14:00.117966');
INSERT INTO "django_admin_log" VALUES (66,'4','KAA 123T',2,'[{"changed": {"fields": ["Status"]}}]',13,1,'2024-08-12 04:10:36.393936');
INSERT INTO "django_admin_log" VALUES (67,'11','Auction 0521348a-dc19-4e85-83a6-de3455bc95ea',1,'[{"added": {}}]',15,1,'2024-08-12 04:27:51.904160');
INSERT INTO "django_admin_log" VALUES (68,'12','Auction bee1b771-02f3-4b3f-a287-918f413a7118',1,'[{"added": {}}]',15,1,'2024-08-12 09:17:34.137543');
INSERT INTO "django_admin_log" VALUES (69,'3','Range Rover',1,'[{"added": {}}]',11,1,'2024-08-12 09:36:10.446192');
INSERT INTO "django_admin_log" VALUES (70,'3','Evoque',1,'[{"added": {}}]',12,1,'2024-08-12 09:36:19.135764');
INSERT INTO "django_admin_log" VALUES (71,'5','KDR 100A',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (13)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (14)"}}]',13,1,'2024-08-12 09:40:51.218052');
INSERT INTO "django_admin_log" VALUES (72,'4','Mercedes',1,'[{"added": {}}]',11,1,'2024-08-12 09:42:53.385639');
INSERT INTO "django_admin_log" VALUES (73,'4','C200',1,'[{"added": {}}]',12,1,'2024-08-12 09:43:01.987291');
INSERT INTO "django_admin_log" VALUES (74,'6','KDR 100A.',1,'[{"added": {}}]',13,1,'2024-08-12 09:44:40.892168');
INSERT INTO "django_admin_log" VALUES (75,'6','KDR 100B',2,'[{"changed": {"fields": ["Registration no"]}}]',13,1,'2024-08-12 09:45:51.580486');
INSERT INTO "django_admin_log" VALUES (76,'6','KDR 100B',2,'[{"changed": {"fields": ["File"]}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (15)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (16)"}}]',13,1,'2024-08-12 09:51:02.016213');
INSERT INTO "django_admin_log" VALUES (77,'13','Auction 55bac2ef-c468-471d-bcba-c64781f806a2',1,'[{"added": {}}]',15,1,'2024-08-12 10:08:11.828206');
INSERT INTO "django_admin_log" VALUES (78,'5','KDR 100A',2,'[{"changed": {"fields": ["Reserve price"]}}]',13,1,'2024-08-12 11:10:32.496779');
INSERT INTO "django_admin_log" VALUES (79,'14','Auction 3153c14a-8746-479c-923d-38bf507aff66',1,'[{"added": {}}]',15,1,'2024-08-13 03:42:00.343021');
INSERT INTO "django_admin_log" VALUES (80,'15','Auction 4b5c4e36-e393-4e13-90f0-2587c50d289b',1,'[{"added": {}}]',15,1,'2024-08-13 03:53:11.017723');
INSERT INTO "django_admin_log" VALUES (81,'16','Auction f454f553-75a3-4c6d-9bf1-fb25d6e46135',1,'[{"added": {}}]',15,1,'2024-08-13 03:59:21.085936');
INSERT INTO "django_admin_log" VALUES (82,'17','Auction 5f6f4abb-be2e-4898-9e68-39d5a20c231a',1,'[{"added": {}}]',15,1,'2024-08-19 10:02:54.589509');
INSERT INTO "django_admin_log" VALUES (83,'18','Auction cd087c6d-61a4-4d8a-b522-604e8263f55e',1,'[{"added": {}}]',15,1,'2024-08-26 04:39:55.723833');
INSERT INTO "django_admin_log" VALUES (84,'5','vanguard',1,'[{"added": {}}]',12,1,'2024-08-26 04:49:42.065950');
INSERT INTO "django_admin_log" VALUES (85,'7','KDR 100z',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (17)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (18)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (19)"}}]',13,1,'2024-08-26 04:51:40.581114');
INSERT INTO "django_admin_log" VALUES (86,'7','KDR 100Z',2,'[{"changed": {"fields": ["Registration no"]}}]',13,1,'2024-08-26 04:51:55.583519');
INSERT INTO "django_admin_log" VALUES (87,'1','Nairobi',1,'[{"added": {}}]',19,1,'2024-08-28 15:52:07.004592');
INSERT INTO "django_admin_log" VALUES (88,'2','Mombasa',1,'[{"added": {}}]',19,1,'2024-08-28 15:52:36.937429');
INSERT INTO "django_admin_log" VALUES (89,'8','tester''s profile',2,'[{"changed": {"fields": ["Location"]}}]',17,1,'2024-08-28 15:52:41.423586');
INSERT INTO "django_admin_log" VALUES (90,'3','Kisii',1,'[{"added": {}}]',19,1,'2024-08-28 19:32:19.317045');
INSERT INTO "django_admin_log" VALUES (91,'4','Meru',1,'[{"added": {}}]',19,1,'2024-08-28 19:32:23.260472');
INSERT INTO "django_admin_log" VALUES (92,'5','Kisumu',1,'[{"added": {}}]',19,1,'2024-08-28 19:32:28.306010');
INSERT INTO "django_admin_log" VALUES (93,'6','Naivasha',1,'[{"added": {}}]',19,1,'2024-08-28 19:32:33.648315');
INSERT INTO "django_admin_log" VALUES (94,'7','Thika',1,'[{"added": {}}]',19,1,'2024-08-28 19:32:38.886231');
INSERT INTO "django_admin_log" VALUES (95,'8','Kakamega',1,'[{"added": {}}]',19,1,'2024-08-28 19:32:48.585036');
INSERT INTO "django_admin_log" VALUES (96,'19','Auction 6bee665f-e28c-431c-b9b2-200b01ba63e1',1,'[{"added": {}}]',15,1,'2024-08-29 09:46:03.394063');
INSERT INTO "django_admin_log" VALUES (97,'10','mbogomartin215@gmail.com',1,'[{"added": {}}]',4,1,'2024-10-09 04:40:16.389166');
INSERT INTO "django_admin_log" VALUES (98,'10','mbogomartin215@gmail.com',2,'[]',4,1,'2024-10-09 04:40:23.738517');
INSERT INTO "django_admin_log" VALUES (99,'20','Auction ea4d65bc-892f-4f8e-83ff-7ae3e10d606c',1,'[{"added": {}}]',15,1,'2024-10-11 07:54:53.406345');
INSERT INTO "django_admin_log" VALUES (100,'21','Auction 3001d9b3-965d-4db6-89ec-6e9eb6e0275f',1,'[{"added": {}}]',15,1,'2024-10-16 08:29:45.687132');
INSERT INTO "django_admin_log" VALUES (101,'22','Auction cc264dfe-234e-4f67-b6f5-eb67a62f8f76',1,'[{"added": {}}]',15,1,'2024-10-16 09:42:53.003529');
INSERT INTO "django_admin_log" VALUES (102,'38','KAA 123A Ractis in Auction 3001d9b3',3,'',18,1,'2024-10-16 09:43:36.041343');
INSERT INTO "django_admin_log" VALUES (103,'39','KDQ 001Q Cayenne in Auction cc264dfe',3,'',18,1,'2024-10-16 11:20:12.318014');
INSERT INTO "django_admin_log" VALUES (104,'37','KDR 100Z vanguard in Auction ea4d65bc',3,'',18,1,'2024-10-16 11:20:12.327832');
INSERT INTO "django_admin_log" VALUES (105,'22','Auction cc264dfe-234e-4f67-b6f5-eb67a62f8f76',3,'',15,1,'2024-10-16 11:20:27.576175');
INSERT INTO "django_admin_log" VALUES (106,'38',' Bid for KAA 123A by janedoe at Ksh 534364383653',3,'',14,1,'2024-10-16 11:22:24.779667');
INSERT INTO "django_admin_log" VALUES (107,'37',' Bid for KDQ 001Q by janedoe at Ksh 1200000',3,'',14,1,'2024-10-16 11:22:24.787478');
INSERT INTO "django_admin_log" VALUES (108,'36',' Bid for KDQ 001Q by Doeser at Ksh 1200000',3,'',14,1,'2024-10-16 11:22:24.792468');
INSERT INTO "django_admin_log" VALUES (109,'35',' Bid for KAA 123A by john at Ksh 1200000',3,'',14,1,'2024-10-16 11:22:24.796847');
INSERT INTO "django_admin_log" VALUES (110,'34',' Bid for KDR 100Z by mbogo at Ksh 10000',3,'',14,1,'2024-10-16 11:22:24.819913');
INSERT INTO "django_admin_log" VALUES (111,'33',' Bid for KDR 100Z by mbogo at Ksh 1500000',3,'',14,1,'2024-10-16 11:22:24.825897');
INSERT INTO "django_admin_log" VALUES (112,'32',' Bid for KDR 100B by mbogo at Ksh 10200',3,'',14,1,'2024-10-16 11:22:24.830653');
INSERT INTO "django_admin_log" VALUES (113,'31',' Bid for KDR 100B by mbogo at Ksh 12',3,'',14,1,'2024-10-16 11:22:24.837113');
INSERT INTO "django_admin_log" VALUES (114,'30',' Bid for KDR 100Z by mbogo at Ksh 12',3,'',14,1,'2024-10-16 11:22:24.841822');
INSERT INTO "django_admin_log" VALUES (115,'29',' Bid for KDR 100Z by mbogo at Ksh 1500000',3,'',14,1,'2024-10-16 11:22:24.846753');
INSERT INTO "django_admin_log" VALUES (116,'28',' Bid for KDR 100Z by mbogo at Ksh 15000000',3,'',14,1,'2024-10-16 11:22:24.853320');
INSERT INTO "django_admin_log" VALUES (117,'27',' Bid for KDR 100Z by martin at Ksh 12',3,'',14,1,'2024-10-16 11:22:24.858448');
INSERT INTO "django_admin_log" VALUES (118,'26',' Bid for KDR 100Z by martin at Ksh 1500000',3,'',14,1,'2024-10-16 11:22:24.864770');
INSERT INTO "django_admin_log" VALUES (119,'25',' Bid for KDR 100Z by martin at Ksh 1',3,'',14,1,'2024-10-16 11:22:24.869284');
INSERT INTO "django_admin_log" VALUES (120,'24',' Bid for KDR 100Z by martin at Ksh 1000000',3,'',14,1,'2024-10-16 11:22:24.875026');
INSERT INTO "django_admin_log" VALUES (121,'23',' Bid for KDR 100B by mbogo at Ksh 10000000',3,'',14,1,'2024-10-16 11:22:24.881264');
INSERT INTO "django_admin_log" VALUES (122,'22',' Bid for KAA 123T by mbogo at Ksh 10000002',3,'',14,1,'2024-10-16 11:22:24.887212');
INSERT INTO "django_admin_log" VALUES (123,'21',' Bid for KAA 123T by mbogo at Ksh 10000000',3,'',14,1,'2024-10-16 11:22:24.892285');
INSERT INTO "django_admin_log" VALUES (124,'20',' Bid for KDQ 001W by mbogo at Ksh 1200000',3,'',14,1,'2024-10-16 11:22:24.897216');
INSERT INTO "django_admin_log" VALUES (125,'19',' Bid for KDQ 001W by mbogo at Ksh 1200000',3,'',14,1,'2024-10-16 11:22:24.901987');
INSERT INTO "django_admin_log" VALUES (126,'18',' Bid for KDR 100A by mbogo at Ksh 12000000',3,'',14,1,'2024-10-16 11:22:24.907230');
INSERT INTO "django_admin_log" VALUES (127,'17',' Bid for KDR 100A by mbogo at Ksh 10000000',3,'',14,1,'2024-10-16 11:22:24.913340');
INSERT INTO "django_admin_log" VALUES (128,'16',' Bid for KDQ 001Q by mbogo at Ksh 5821485',3,'',14,1,'2024-10-16 11:22:24.918617');
INSERT INTO "django_admin_log" VALUES (129,'15',' Bid for KAA 123A by Doeser at Ksh 1200001',3,'',14,1,'2024-10-16 11:22:24.924931');
INSERT INTO "django_admin_log" VALUES (130,'14',' Bid for KAA 123A by mbogo at Ksh 1200000',3,'',14,1,'2024-10-16 11:22:24.930110');
INSERT INTO "django_admin_log" VALUES (131,'36','KAA 123A Ractis in Auction ea4d65bc',3,'',18,1,'2024-10-16 11:50:18.073776');
INSERT INTO "django_admin_log" VALUES (132,'35','KDR 100Z vanguard in Auction 6bee665f',3,'',18,1,'2024-10-16 11:50:18.087852');
INSERT INTO "django_admin_log" VALUES (133,'34','KDR 100B C200 in Auction 6bee665f',3,'',18,1,'2024-10-16 11:50:18.103185');
INSERT INTO "django_admin_log" VALUES (134,'33','KDR 100B C200 in Auction cd087c6d',3,'',18,1,'2024-10-16 11:50:18.116655');
INSERT INTO "django_admin_log" VALUES (135,'32','KDR 100B C200 in Auction 5f6f4abb',3,'',18,1,'2024-10-16 11:50:18.127386');
INSERT INTO "django_admin_log" VALUES (136,'31','KAA 123T Cayenne in Auction 5f6f4abb',3,'',18,1,'2024-10-16 11:50:18.138711');
INSERT INTO "django_admin_log" VALUES (137,'30','KDR 100B C200 in Auction f454f553',3,'',18,1,'2024-10-16 11:50:18.148577');
INSERT INTO "django_admin_log" VALUES (138,'29','KAA 123T Cayenne in Auction f454f553',3,'',18,1,'2024-10-16 11:50:18.159793');
INSERT INTO "django_admin_log" VALUES (139,'28','KDQ 001W Ractis in Auction 4b5c4e36',3,'',18,1,'2024-10-16 11:50:18.169756');
INSERT INTO "django_admin_log" VALUES (140,'27','KDR 100A Evoque in Auction 3153c14a',3,'',18,1,'2024-10-16 11:50:18.180971');
INSERT INTO "django_admin_log" VALUES (141,'26','KDQ 001W Ractis in Auction 3153c14a',3,'',18,1,'2024-10-16 11:50:18.192445');
INSERT INTO "django_admin_log" VALUES (142,'25','KDQ 001W Ractis in Auction 55bac2ef',3,'',18,1,'2024-10-16 11:50:18.202369');
INSERT INTO "django_admin_log" VALUES (143,'24','KAA 123T Cayenne in Auction bee1b771',3,'',18,1,'2024-10-16 11:50:18.213875');
INSERT INTO "django_admin_log" VALUES (144,'23','KAA 123T Cayenne in Auction 0521348a',3,'',18,1,'2024-10-16 11:50:18.235824');
INSERT INTO "django_admin_log" VALUES (145,'22','KAA 123T Cayenne in Auction 1f88d4d7',3,'',18,1,'2024-10-16 11:50:18.248269');
INSERT INTO "django_admin_log" VALUES (146,'21','KDQ 001W Ractis in Auction 1f88d4d7',3,'',18,1,'2024-10-16 11:50:18.257576');
INSERT INTO "django_admin_log" VALUES (147,'20','KAA 123T Cayenne in Auction 698295a2',3,'',18,1,'2024-10-16 11:50:18.268178');
INSERT INTO "django_admin_log" VALUES (148,'19','KDQ 001W Ractis in Auction 698295a2',3,'',18,1,'2024-10-16 11:50:18.279168');
INSERT INTO "django_admin_log" VALUES (149,'18','KAA 123T Cayenne in Auction 679e68e3',3,'',18,1,'2024-10-16 11:50:18.290023');
INSERT INTO "django_admin_log" VALUES (150,'17','KDQ 001W Ractis in Auction 679e68e3',3,'',18,1,'2024-10-16 11:50:18.301058');
INSERT INTO "django_admin_log" VALUES (151,'16','KDQ 001Q Cayenne in Auction 679e68e3',3,'',18,1,'2024-10-16 11:50:18.314373');
INSERT INTO "django_admin_log" VALUES (152,'15','KAA 123A Ractis in Auction 679e68e3',3,'',18,1,'2024-10-16 11:50:18.324774');
INSERT INTO "django_admin_log" VALUES (153,'14','KDQ 001Q Cayenne in Auction b510f98d',3,'',18,1,'2024-10-16 11:50:18.336653');
INSERT INTO "django_admin_log" VALUES (154,'13','KDQ 001Q Cayenne in Auction 64aa8b08',3,'',18,1,'2024-10-16 11:50:18.347740');
INSERT INTO "django_admin_log" VALUES (155,'12','KAA 123A Ractis in Auction 64aa8b08',3,'',18,1,'2024-10-16 11:50:18.357860');
INSERT INTO "django_admin_log" VALUES (156,'11','KAA 123T Cayenne in Auction fe13de79',3,'',18,1,'2024-10-16 11:50:18.369895');
INSERT INTO "django_admin_log" VALUES (157,'10','KDQ 001W Ractis in Auction fe13de79',3,'',18,1,'2024-10-16 11:50:18.380840');
INSERT INTO "django_admin_log" VALUES (158,'21','Auction 3001d9b3-965d-4db6-89ec-6e9eb6e0275f',3,'',15,1,'2024-10-16 11:50:29.045796');
INSERT INTO "django_admin_log" VALUES (159,'20','Auction ea4d65bc-892f-4f8e-83ff-7ae3e10d606c',3,'',15,1,'2024-10-16 11:50:29.059097');
INSERT INTO "django_admin_log" VALUES (160,'19','Auction 6bee665f-e28c-431c-b9b2-200b01ba63e1',3,'',15,1,'2024-10-16 11:50:29.069796');
INSERT INTO "django_admin_log" VALUES (161,'18','Auction cd087c6d-61a4-4d8a-b522-604e8263f55e',3,'',15,1,'2024-10-16 11:50:29.079717');
INSERT INTO "django_admin_log" VALUES (162,'17','Auction 5f6f4abb-be2e-4898-9e68-39d5a20c231a',3,'',15,1,'2024-10-16 11:50:29.091114');
INSERT INTO "django_admin_log" VALUES (163,'16','Auction f454f553-75a3-4c6d-9bf1-fb25d6e46135',3,'',15,1,'2024-10-16 11:50:29.110018');
INSERT INTO "django_admin_log" VALUES (164,'15','Auction 4b5c4e36-e393-4e13-90f0-2587c50d289b',3,'',15,1,'2024-10-16 11:50:29.120126');
INSERT INTO "django_admin_log" VALUES (165,'14','Auction 3153c14a-8746-479c-923d-38bf507aff66',3,'',15,1,'2024-10-16 11:50:29.129787');
INSERT INTO "django_admin_log" VALUES (166,'13','Auction 55bac2ef-c468-471d-bcba-c64781f806a2',3,'',15,1,'2024-10-16 11:50:29.140039');
INSERT INTO "django_admin_log" VALUES (167,'12','Auction bee1b771-02f3-4b3f-a287-918f413a7118',3,'',15,1,'2024-10-16 11:50:29.149704');
INSERT INTO "django_admin_log" VALUES (168,'11','Auction 0521348a-dc19-4e85-83a6-de3455bc95ea',3,'',15,1,'2024-10-16 11:50:29.160865');
INSERT INTO "django_admin_log" VALUES (169,'10','Auction 1f88d4d7-1552-4ca1-8ec8-9493dca8ce28',3,'',15,1,'2024-10-16 11:50:29.171288');
INSERT INTO "django_admin_log" VALUES (170,'9','Auction 698295a2-8fb5-4f85-b07f-62911c37ceef',3,'',15,1,'2024-10-16 11:50:29.181165');
INSERT INTO "django_admin_log" VALUES (171,'8','Auction 679e68e3-6a2a-4ba6-83e2-45aa5f0bb393',3,'',15,1,'2024-10-16 11:50:29.190548');
INSERT INTO "django_admin_log" VALUES (172,'7','Auction b510f98d-9e60-4377-8e5b-a966d6480e46',3,'',15,1,'2024-10-16 11:50:29.200467');
INSERT INTO "django_admin_log" VALUES (173,'6','Auction 64aa8b08-97ee-4034-b54a-20e6ce0e08c0',3,'',15,1,'2024-10-16 11:50:29.211028');
INSERT INTO "django_admin_log" VALUES (174,'5','Auction fe13de79-5c61-4c1d-8160-9fb56edf4d09',3,'',15,1,'2024-10-16 11:50:29.220578');
INSERT INTO "django_admin_log" VALUES (175,'23','Auction 4af19826-12bc-4302-9402-31b5a72b7b28',1,'[{"added": {}}]',15,1,'2024-10-16 11:50:54.644816');
INSERT INTO "django_admin_log" VALUES (176,'24','Auction 72beee4f-94b2-4f42-b814-7e0f0bbfc56a',1,'[{"added": {}}]',15,1,'2024-10-16 12:24:10.222251');
INSERT INTO "django_admin_log" VALUES (177,'9','janedoe',2,'[{"changed": {"fields": ["Email address"]}}]',4,1,'2024-10-16 12:24:42.480303');
INSERT INTO "django_admin_log" VALUES (178,'25','Auction 3ed376ff-fa3b-4327-80a3-73d9512d96b8',1,'[{"added": {}}]',15,1,'2024-10-16 12:45:30.724584');
INSERT INTO "django_admin_log" VALUES (179,'1','mbogo',2,'[{"changed": {"fields": ["Email address"]}}]',4,1,'2024-10-16 12:46:01.787278');
INSERT INTO "django_admin_log" VALUES (180,'26','Auction e65612b2-beaf-4791-bf70-55bd721f28f4',1,'[{"added": {}}]',15,1,'2024-10-17 09:52:49.343243');
INSERT INTO "django_admin_log" VALUES (181,'48','KAA 123T Cayenne in Auction e65612b2',3,'',18,1,'2024-10-24 06:19:18.487050');
INSERT INTO "django_admin_log" VALUES (182,'47','KDQ 001W Ractis in Auction e65612b2',3,'',18,1,'2024-10-24 06:19:18.498832');
INSERT INTO "django_admin_log" VALUES (183,'46','KDR 100B C200 in Auction 3ed376ff',3,'',18,1,'2024-10-24 06:19:18.509288');
INSERT INTO "django_admin_log" VALUES (184,'45','KDR 100A Evoque in Auction 3ed376ff',3,'',18,1,'2024-10-24 06:19:18.520629');
INSERT INTO "django_admin_log" VALUES (185,'44','KDR 100Z vanguard in Auction 72beee4f',3,'',18,1,'2024-10-24 06:19:18.531114');
INSERT INTO "django_admin_log" VALUES (186,'43','KDR 100B C200 in Auction 72beee4f',3,'',18,1,'2024-10-24 06:19:18.542251');
INSERT INTO "django_admin_log" VALUES (187,'42','KAA 123T Cayenne in Auction 4af19826',3,'',18,1,'2024-10-24 06:19:18.552370');
INSERT INTO "django_admin_log" VALUES (188,'41','KDQ 001W Ractis in Auction 4af19826',3,'',18,1,'2024-10-24 06:19:18.563766');
INSERT INTO "django_admin_log" VALUES (189,'40','KAA 123A Ractis in Auction 4af19826',3,'',18,1,'2024-10-24 06:19:18.575305');
INSERT INTO "django_admin_log" VALUES (190,'26','Auction e65612b2-beaf-4791-bf70-55bd721f28f4',3,'',15,1,'2024-10-24 06:19:25.038037');
INSERT INTO "django_admin_log" VALUES (191,'25','Auction 3ed376ff-fa3b-4327-80a3-73d9512d96b8',3,'',15,1,'2024-10-24 06:19:25.050917');
INSERT INTO "django_admin_log" VALUES (192,'24','Auction 72beee4f-94b2-4f42-b814-7e0f0bbfc56a',3,'',15,1,'2024-10-24 06:19:25.063613');
INSERT INTO "django_admin_log" VALUES (193,'23','Auction 4af19826-12bc-4302-9402-31b5a72b7b28',3,'',15,1,'2024-10-24 06:19:25.084409');
INSERT INTO "django_admin_log" VALUES (194,'56',' Bid for KAA 123T by Doeser at Ksh 4600000',3,'',14,1,'2024-10-24 06:19:33.210065');
INSERT INTO "django_admin_log" VALUES (195,'55',' Bid for KDQ 001W by mbogo at Ksh 1300000',3,'',14,1,'2024-10-24 06:19:33.221265');
INSERT INTO "django_admin_log" VALUES (196,'54',' Bid for KDQ 001Q by test1 at Ksh 3600000',3,'',14,1,'2024-10-24 06:19:33.231696');
INSERT INTO "django_admin_log" VALUES (197,'53',' Bid for KAA 123T by test1 at Ksh 1000000',3,'',14,1,'2024-10-24 06:19:33.243979');
INSERT INTO "django_admin_log" VALUES (198,'52',' Bid for KDQ 001W by test1 at Ksh 1000000',3,'',14,1,'2024-10-24 06:19:33.254524');
INSERT INTO "django_admin_log" VALUES (199,'51',' Bid for KAA 123T by mbogo at Ksh 1200000',3,'',14,1,'2024-10-24 06:19:33.267206');
INSERT INTO "django_admin_log" VALUES (200,'50',' Bid for KDQ 001W by martin at Ksh 1000000',3,'',14,1,'2024-10-24 06:19:33.279305');
INSERT INTO "django_admin_log" VALUES (201,'49',' Bid for KDQ 001Q by mbogo at Ksh 1200000',3,'',14,1,'2024-10-24 06:19:33.289311');
INSERT INTO "django_admin_log" VALUES (202,'48',' Bid for KDR 100A by martin at Ksh 3020000',3,'',14,1,'2024-10-24 06:19:33.304206');
INSERT INTO "django_admin_log" VALUES (203,'47',' Bid for KDR 100A by janedoe at Ksh 9020000',3,'',14,1,'2024-10-24 06:19:33.315488');
INSERT INTO "django_admin_log" VALUES (204,'46',' Bid for KDR 100B by mbogo at Ksh 7600000',3,'',14,1,'2024-10-24 06:19:33.326814');
INSERT INTO "django_admin_log" VALUES (205,'45',' Bid for KDR 100A by mbogo at Ksh 9100000',3,'',14,1,'2024-10-24 06:19:33.337057');
INSERT INTO "django_admin_log" VALUES (206,'44',' Bid for KDR 100Z by martin at Ksh 1240000',3,'',14,1,'2024-10-24 06:19:33.349930');
INSERT INTO "django_admin_log" VALUES (207,'43',' Bid for KDR 100Z by mbogo at Ksh 1250000',3,'',14,1,'2024-10-24 06:19:33.363001');
INSERT INTO "django_admin_log" VALUES (208,'42',' Bid for KAA 123T by janedoe at Ksh 1200000',3,'',14,1,'2024-10-24 06:19:33.374268');
INSERT INTO "django_admin_log" VALUES (209,'41',' Bid for KDQ 001W by janedoe at Ksh 1000000',3,'',14,1,'2024-10-24 06:19:33.384400');
INSERT INTO "django_admin_log" VALUES (210,'40',' Bid for KDR 100B by janedoe at Ksh 6000000',3,'',14,1,'2024-10-24 06:19:33.394857');
INSERT INTO "django_admin_log" VALUES (211,'39',' Bid for KAA 123A by janedoe at Ksh 1200000',3,'',14,1,'2024-10-24 06:19:33.405821');
INSERT INTO "django_admin_log" VALUES (212,'1','mbogomartin25@gmail.com',1,'[{"added": {}}]',20,1,'2024-10-24 07:05:17.201132');
INSERT INTO "django_admin_log" VALUES (213,'2','fuel@riverlong.com',1,'[{"added": {}}]',20,1,'2024-10-24 07:05:33.594341');
INSERT INTO "django_admin_log" VALUES (214,'3','Electric',2,'[{"changed": {"fields": ["Name"]}}]',7,1,'2024-10-26 10:04:23.233236');
INSERT INTO "django_admin_log" VALUES (215,'1','Yard object (1)',1,'[{"added": {}}]',22,1,'2024-10-29 14:22:38.011704');
INSERT INTO "django_admin_log" VALUES (216,'7','KDR 100Z',2,'[{"changed": {"fields": ["Yard"]}}]',13,1,'2024-10-29 14:27:39.761834');
INSERT INTO "django_admin_log" VALUES (217,'2','StarTruck Yard',1,'[{"added": {}}]',22,1,'2024-10-29 14:30:09.820512');
INSERT INTO "django_admin_log" VALUES (218,'6','KDR 100B',2,'[{"changed": {"fields": ["Yard"]}}]',13,1,'2024-10-29 14:30:27.335939');
INSERT INTO "django_admin_log" VALUES (219,'1','Financier object (1)',1,'[{"added": {}}]',21,1,'2024-10-29 14:46:33.501998');
INSERT INTO "django_admin_log" VALUES (220,'3','Electric',3,'',7,1,'2024-10-30 04:56:29.092448');
INSERT INTO "django_admin_log" VALUES (221,'2','Doeser',2,'[{"changed": {"fields": ["Email address"]}}]',4,1,'2024-10-30 11:14:35.732910');
INSERT INTO "django_admin_log" VALUES (222,'3','KDQ 001W',2,'[{"changed": {"fields": ["Financier", "Yard"]}}]',13,1,'2024-11-01 22:01:25.057706');
INSERT INTO "django_admin_log" VALUES (223,'2','Test Financier',1,'[{"added": {}}]',21,1,'2024-11-03 06:23:11.803033');
INSERT INTO "django_admin_log" VALUES (224,'1','Staff',1,'[{"added": {}}]',3,1,'2024-11-03 06:35:18.702302');
INSERT INTO "django_admin_log" VALUES (225,'2','Administrators',1,'[{"added": {}}]',3,1,'2024-11-03 06:35:28.272089');
INSERT INTO "django_admin_log" VALUES (226,'3','Financiers',1,'[{"added": {}}]',3,1,'2024-11-03 06:35:43.327462');
INSERT INTO "django_admin_log" VALUES (227,'4','Sales',1,'[{"added": {}}]',3,1,'2024-11-03 06:37:11.952699');
INSERT INTO "django_admin_log" VALUES (228,'7','Angela',2,'[{"changed": {"fields": ["Groups"]}}]',4,1,'2024-11-03 06:37:30.734611');
INSERT INTO "django_admin_log" VALUES (229,'9','janedoe',2,'[]',4,1,'2024-11-03 06:37:55.885794');
INSERT INTO "django_admin_log" VALUES (230,'27','Auction 74685cb9-e092-4bd3-9f14-3a9e63024c63',1,'[{"added": {}}]',15,1,'2024-11-03 07:31:11.899746');
INSERT INTO "django_admin_log" VALUES (231,'9','janedoe',2,'[{"changed": {"fields": ["Email address"]}}]',4,1,'2024-11-03 07:35:35.077186');
INSERT INTO "django_admin_log" VALUES (232,'67',' Bid for KDQ 001W by janedoe at Ksh 1000000',3,'',14,1,'2024-11-03 07:35:42.788480');
INSERT INTO "django_admin_log" VALUES (233,'66',' Bid for KAA 123A by Doeser at Ksh 1200000',3,'',14,1,'2024-11-03 07:35:42.906346');
INSERT INTO "django_admin_log" VALUES (234,'65',' Bid for KDR 100B by mbogo at Ksh 3600000',3,'',14,1,'2024-11-03 07:35:43.002843');
INSERT INTO "django_admin_log" VALUES (235,'62',' Bid for KDR 100B by Doeser at Ksh 1200000',3,'',14,1,'2024-11-03 07:35:43.106799');
INSERT INTO "django_admin_log" VALUES (236,'59',' Bid for KDQ 001W by mbogo at Ksh 1000000',3,'',14,1,'2024-11-03 07:35:43.190821');
INSERT INTO "django_admin_log" VALUES (237,'58',' Bid for KAA 123A by mbogo at Ksh 1000000',3,'',14,1,'2024-11-03 07:35:43.279586');
INSERT INTO "django_admin_log" VALUES (238,'57',' Bid for KDR 100Z by mbogo at Ksh 1200000',3,'',14,1,'2024-11-03 07:35:43.368141');
INSERT INTO "django_admin_log" VALUES (239,'28','Auction 1e32e297-f219-4edf-999f-51dc34da922f',1,'[{"added": {}}]',15,1,'2024-11-07 11:58:11.621704');
INSERT INTO "django_admin_log" VALUES (240,'73',' Bid for KAA 123A by Doeser at Ksh 1500000',3,'',14,1,'2024-11-10 10:29:36.490859');
INSERT INTO "django_admin_log" VALUES (241,'72',' Bid for KDR 100Z by janedoe at Ksh 1000000',3,'',14,1,'2024-11-10 10:29:36.752095');
INSERT INTO "django_admin_log" VALUES (242,'71',' Bid for KDR 100Z by mbogo at Ksh 1000000',3,'',14,1,'2024-11-10 10:29:37.079631');
INSERT INTO "django_admin_log" VALUES (243,'70',' Bid for KAA 123A by mbogo at Ksh 1200000',3,'',14,1,'2024-11-10 10:29:37.230044');
INSERT INTO "django_admin_log" VALUES (244,'69',' Bid for KDR 100B by mbogo at Ksh 8000000',3,'',14,1,'2024-11-10 10:29:37.454981');
INSERT INTO "django_admin_log" VALUES (245,'68',' Bid for KDQ 001W by janedoe at Ksh 1500000',3,'',14,1,'2024-11-10 10:29:37.871752');
INSERT INTO "django_admin_log" VALUES (246,'53','KDR 100B C200 in Auction 1e32e297',3,'',18,1,'2024-11-10 10:29:55.443164');
INSERT INTO "django_admin_log" VALUES (247,'52','KAA 123A Ractis in Auction 1e32e297',3,'',18,1,'2024-11-10 10:29:55.549720');
INSERT INTO "django_admin_log" VALUES (248,'51','KDR 100Z vanguard in Auction 74685cb9',3,'',18,1,'2024-11-10 10:29:55.637409');
INSERT INTO "django_admin_log" VALUES (249,'50','KDR 100B C200 in Auction 74685cb9',3,'',18,1,'2024-11-10 10:29:55.711005');
INSERT INTO "django_admin_log" VALUES (250,'49','KDQ 001W Ractis in Auction 74685cb9',3,'',18,1,'2024-11-10 10:29:55.803211');
INSERT INTO "django_admin_log" VALUES (251,'28','Auction 1e32e297-f219-4edf-999f-51dc34da922f',3,'',15,1,'2024-11-10 10:30:09.812641');
INSERT INTO "django_admin_log" VALUES (252,'27','Auction 74685cb9-e092-4bd3-9f14-3a9e63024c63',3,'',15,1,'2024-11-10 10:30:09.917978');
INSERT INTO "django_admin_log" VALUES (253,'7','KDR 100Z',2,'[{"changed": {"fields": ["Financier"]}}]',13,1,'2024-11-10 10:30:31.250069');
INSERT INTO "django_admin_log" VALUES (254,'6','KDR 100B',2,'[{"changed": {"fields": ["Financier", "Yard"]}}]',13,1,'2024-11-10 10:30:41.744944');
INSERT INTO "django_admin_log" VALUES (255,'3','KDQ 001W',2,'[{"changed": {"fields": ["Yard"]}}]',13,1,'2024-11-10 10:30:48.919225');
INSERT INTO "django_admin_log" VALUES (256,'1','KAA 123A',2,'[{"changed": {"fields": ["Financier"]}}]',13,1,'2024-11-10 10:30:54.513946');
INSERT INTO "django_admin_log" VALUES (257,'1','KAA 123A',2,'[{"changed": {"fields": ["Yard"]}}]',13,1,'2024-11-10 10:52:53.415864');
INSERT INTO "django_admin_log" VALUES (258,'2','Adminis',2,'[{"changed": {"fields": ["Name"]}}]',3,1,'2024-11-10 11:24:56.315257');
INSERT INTO "django_admin_log" VALUES (259,'4','Sales',2,'[]',3,1,'2024-11-10 11:25:00.729211');
INSERT INTO "django_admin_log" VALUES (260,'2','Admins',2,'[{"changed": {"fields": ["Name"]}}]',3,1,'2024-11-10 11:27:39.470555');
INSERT INTO "django_admin_log" VALUES (261,'1','mbogo',2,'[{"changed": {"fields": ["Groups"]}}]',4,1,'2024-11-10 11:27:56.026862');
INSERT INTO "django_admin_log" VALUES (262,'6','KDR 100B',2,'[{"changed": {"fields": ["Is approved"]}}]',13,1,'2024-11-10 11:31:35.430030');
INSERT INTO "django_admin_log" VALUES (263,'6','KDR 100B',2,'[{"changed": {"fields": ["Is approved"]}}]',13,1,'2024-11-10 11:31:45.666042');
INSERT INTO "django_admin_log" VALUES (264,'9','janedoe',2,'[{"changed": {"fields": ["Staff status", "Groups"]}}]',4,1,'2024-11-10 11:36:33.857137');
INSERT INTO "django_admin_log" VALUES (265,'4','Sales',2,'[]',3,1,'2024-11-10 11:36:51.399385');
INSERT INTO "django_admin_log" VALUES (266,'5','Nissan',1,'[{"added": {}}]',11,9,'2024-11-10 18:39:46.359445');
INSERT INTO "django_admin_log" VALUES (267,'6','Note',1,'[{"added": {}}]',12,9,'2024-11-10 18:39:59.375655');
INSERT INTO "django_admin_log" VALUES (268,'8','KDR 023W',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (20)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (21)"}}]',13,9,'2024-11-10 18:41:02.414158');
INSERT INTO "django_admin_log" VALUES (269,'1','KAA 123A',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 10:11:00.388727');
INSERT INTO "django_admin_log" VALUES (270,'3','KDQ 001W',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 10:53:48.941780');
INSERT INTO "django_admin_log" VALUES (271,'1','KAA 123A',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 10:53:58.610231');
INSERT INTO "django_admin_log" VALUES (272,'1','KAA 123A',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 10:54:05.992481');
INSERT INTO "django_admin_log" VALUES (273,'1','KAA 123A',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 10:54:32.841742');
INSERT INTO "django_admin_log" VALUES (274,'3','KDQ 001W',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 11:01:50.280000');
INSERT INTO "django_admin_log" VALUES (275,'8','KDR 023W',2,'[{"changed": {"fields": ["File", "Is hotsale"]}}]',13,9,'2024-11-17 11:04:02.549783');
INSERT INTO "django_admin_log" VALUES (276,'8','KDR 023W',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 12:09:44.104530');
INSERT INTO "django_admin_log" VALUES (277,'7','KDR 100Z',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 12:09:50.504022');
INSERT INTO "django_admin_log" VALUES (278,'8','KDR 023W',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 12:11:06.546414');
INSERT INTO "django_admin_log" VALUES (279,'7','KDR 100Z',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 12:11:14.272807');
INSERT INTO "django_admin_log" VALUES (280,'7','KDR 100Z',2,'[{"changed": {"fields": ["File"]}}, {"changed": {"name": "vehicle image", "object": "VehicleImage object (19)", "fields": ["Image"]}}]',13,9,'2024-11-17 12:23:08.031414');
INSERT INTO "django_admin_log" VALUES (281,'7','KDR 100Z',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 12:23:33.490371');
INSERT INTO "django_admin_log" VALUES (282,'8','KDR 023W',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 12:23:40.817486');
INSERT INTO "django_admin_log" VALUES (283,'3','KDQ 001W',2,'[{"changed": {"fields": ["File"]}}, {"changed": {"name": "vehicle image", "object": "VehicleImage object (8)", "fields": ["Image"]}}]',13,9,'2024-11-17 12:25:40.733077');
INSERT INTO "django_admin_log" VALUES (284,'3','KDQ 001W',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 12:26:02.924077');
INSERT INTO "django_admin_log" VALUES (285,'7','KDR 100Z',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 12:26:09.578774');
INSERT INTO "django_admin_log" VALUES (286,'8','KDR 023W',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 16:19:06.230516');
INSERT INTO "django_admin_log" VALUES (287,'3','KDQ 001W',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 16:19:18.549969');
INSERT INTO "django_admin_log" VALUES (288,'3','KDQ 001W',2,'[]',13,9,'2024-11-17 16:31:53.938919');
INSERT INTO "django_admin_log" VALUES (289,'8','KDR 023W',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 16:32:06.739053');
INSERT INTO "django_admin_log" VALUES (290,'3','KDQ 001W',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,9,'2024-11-17 16:32:33.334768');
INSERT INTO "django_admin_log" VALUES (291,'13','agango',1,'[{"added": {}}]',4,1,'2024-11-18 04:38:37.889732');
INSERT INTO "django_admin_log" VALUES (292,'13','agango',2,'[{"changed": {"fields": ["First name", "Last name", "Email address", "Staff status", "Superuser status"]}}]',4,1,'2024-11-18 04:39:06.678254');
INSERT INTO "django_admin_log" VALUES (293,'8','KDR 023W',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,13,'2024-11-18 05:03:41.498840');
INSERT INTO "django_admin_log" VALUES (294,'6','KDR 100B',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,13,'2024-11-18 05:04:33.878295');
INSERT INTO "django_admin_log" VALUES (295,'3','KDQ 001W',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,13,'2024-11-18 05:10:56.355222');
INSERT INTO "django_admin_log" VALUES (296,'3','walteragango@gmail.com',1,'[{"added": {}}]',20,13,'2024-11-18 05:48:32.806731');
INSERT INTO "django_admin_log" VALUES (297,'4','wodhiambo@riverlong.com',1,'[{"added": {}}]',20,13,'2024-11-18 05:49:13.191001');
INSERT INTO "django_admin_log" VALUES (298,'6','KDR 100B',2,'[]',13,13,'2024-11-18 06:18:42.057008');
INSERT INTO "django_admin_log" VALUES (299,'3','KDQ 001W',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,13,'2024-11-18 06:19:18.141084');
INSERT INTO "django_admin_log" VALUES (300,'6','KDR 100B',2,'[]',13,13,'2024-11-18 06:19:30.532855');
INSERT INTO "django_admin_log" VALUES (301,'77',' Bid for KDQ 001W by agango at Ksh 122222',3,'',14,1,'2025-01-03 07:20:44.706496');
INSERT INTO "django_admin_log" VALUES (302,'76',' Bid for KDR 100B by janedoe at Ksh 1500000',3,'',14,1,'2025-01-03 07:20:44.744408');
INSERT INTO "django_admin_log" VALUES (303,'75',' Bid for KDR 023W by mbogo at Ksh 2000000',3,'',14,1,'2025-01-03 07:20:44.832097');
INSERT INTO "django_admin_log" VALUES (304,'74',' Bid for KDQ 001W by mbogo at Ksh 1000',3,'',14,1,'2025-01-03 07:20:44.848224');
INSERT INTO "django_admin_log" VALUES (305,'2','Doeser',2,'[{"changed": {"fields": ["Groups"]}}]',4,1,'2025-01-03 07:23:06.623998');
INSERT INTO "django_admin_log" VALUES (306,'1','mbogo',2,'[{"changed": {"fields": ["Groups"]}}]',4,1,'2025-01-03 07:23:27.964820');
INSERT INTO "django_admin_log" VALUES (307,'1','mbogo',2,'[{"changed": {"fields": ["Groups"]}}]',4,1,'2025-01-03 07:24:16.024872');
INSERT INTO "django_admin_log" VALUES (308,'6','KDR 100B',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,1,'2025-01-03 07:24:31.946938');
INSERT INTO "django_admin_log" VALUES (309,'14','walter',1,'[{"added": {}}]',4,1,'2025-01-03 11:46:26.087042');
INSERT INTO "django_admin_log" VALUES (310,'14','walter',2,'[{"changed": {"fields": ["First name", "Last name", "Email address", "Staff status", "Superuser status", "Groups"]}}]',4,1,'2025-01-03 11:49:18.354712');
INSERT INTO "django_admin_log" VALUES (311,'7','Carrera',1,'[{"added": {}}]',12,1,'2025-01-03 13:36:27.505030');
INSERT INTO "django_admin_log" VALUES (312,'4','Hatchback',1,'[{"added": {}}]',9,1,'2025-01-03 13:38:05.329406');
INSERT INTO "django_admin_log" VALUES (313,'9','KDS 001A',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (22)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (23)"}}]',13,1,'2025-01-03 13:39:38.538019');
INSERT INTO "django_admin_log" VALUES (314,'4','wodhiambo@riverlong.com',3,'',20,1,'2025-01-03 13:41:04.180016');
INSERT INTO "django_admin_log" VALUES (315,'3','walteragango@gmail.com',3,'',20,1,'2025-01-03 13:41:04.210787');
INSERT INTO "django_admin_log" VALUES (316,'2','fuel@riverlong.com',3,'',20,1,'2025-01-03 13:41:14.103288');
INSERT INTO "django_admin_log" VALUES (317,'1','mbogo',2,'[{"changed": {"fields": ["Groups"]}}]',4,1,'2025-01-03 13:43:04.824621');
INSERT INTO "django_admin_log" VALUES (318,'1','mbogo',2,'[{"changed": {"fields": ["Groups", "User permissions"]}}]',4,1,'2025-01-03 13:44:08.433857');
INSERT INTO "django_admin_log" VALUES (319,'1','mbogo',2,'[{"changed": {"fields": ["Groups"]}}]',4,1,'2025-01-03 13:46:50.187219');
INSERT INTO "django_admin_log" VALUES (320,'15','esther',1,'[{"added": {}}]',4,14,'2025-01-04 07:00:14.753834');
INSERT INTO "django_admin_log" VALUES (321,'15','esther',2,'[{"changed": {"fields": ["First name", "Last name", "Email address"]}}]',4,14,'2025-01-04 07:16:19.981222');
INSERT INTO "django_admin_log" VALUES (322,'15','esther',2,'[{"changed": {"fields": ["Groups"]}}]',4,14,'2025-01-04 07:19:51.459420');
INSERT INTO "django_admin_log" VALUES (323,'15','esther',2,'[{"changed": {"fields": ["Staff status"]}}]',4,14,'2025-01-04 07:23:23.808313');
INSERT INTO "django_admin_log" VALUES (324,'15','esther',2,'[{"changed": {"fields": ["Superuser status"]}}]',4,14,'2025-01-04 07:24:20.313290');
INSERT INTO "django_admin_log" VALUES (325,'7','KDR 100Z',3,'',13,1,'2025-01-08 06:44:37.526880');
INSERT INTO "django_admin_log" VALUES (326,'3','KDQ 001W',3,'',13,1,'2025-01-08 06:44:37.535874');
INSERT INTO "django_admin_log" VALUES (327,'1','KAA 123A',3,'',13,1,'2025-01-08 06:44:37.541875');
INSERT INTO "django_admin_log" VALUES (328,'80',' Bid for KDS 001A by mbogo at Ksh 1000000',3,'',14,1,'2025-01-08 06:45:14.005180');
INSERT INTO "django_admin_log" VALUES (329,'79',' Bid for KDR 023W by mbogo at Ksh 1200005',3,'',14,1,'2025-01-08 06:45:14.026674');
INSERT INTO "django_admin_log" VALUES (330,'78',' Bid for KDR 100B by mbogo at Ksh 2500000',3,'',14,1,'2025-01-08 06:45:14.038944');
INSERT INTO "django_admin_log" VALUES (331,'5','mmburu@riverlong.com',1,'[{"added": {}}]',20,1,'2025-01-08 06:48:21.893081');
INSERT INTO "django_admin_log" VALUES (332,'29','Auction c51ca1dd-671f-434a-803b-6f825bd6ec4b',1,'[{"added": {}}]',15,1,'2025-01-08 07:29:57.197285');
INSERT INTO "django_admin_log" VALUES (333,'84',' Bid for KDR 100B by mbogo at Ksh 8000000',3,'',14,1,'2025-01-08 07:30:38.039816');
INSERT INTO "django_admin_log" VALUES (334,'83',' Bid for KDR 023W by mbogo at Ksh 2500000',3,'',14,1,'2025-01-08 07:30:38.049728');
INSERT INTO "django_admin_log" VALUES (335,'87',' Bid for KDS 001A by mbogo at Ksh 10000000',3,'',14,1,'2025-01-08 14:59:52.560165');
INSERT INTO "django_admin_log" VALUES (336,'86',' Bid for KDR 023W by mbogo at Ksh 2000000',3,'',14,1,'2025-01-08 14:59:52.594336');
INSERT INTO "django_admin_log" VALUES (337,'85',' Bid for KDR 100B by mbogo at Ksh 8000000',3,'',14,1,'2025-01-08 14:59:52.608335');
INSERT INTO "django_admin_log" VALUES (338,'89',' Bid for KDR 023W by mbogo at Ksh 3600000',3,'',14,1,'2025-01-08 15:19:37.762192');
INSERT INTO "django_admin_log" VALUES (339,'88',' Bid for KDS 001A by mbogo at Ksh 8000000',3,'',14,1,'2025-01-08 15:19:37.786376');
INSERT INTO "django_admin_log" VALUES (340,'91',' Bid for KDS 001A by mbogo at Ksh 8000000',3,'',14,1,'2025-01-08 15:21:33.297996');
INSERT INTO "django_admin_log" VALUES (341,'90',' Bid for KDR 023W by mbogo at Ksh 2500000',3,'',14,1,'2025-01-08 15:21:33.355725');
INSERT INTO "django_admin_log" VALUES (342,'16','Alex',1,'[{"added": {}}]',4,1,'2025-01-09 08:42:35.814795');
INSERT INTO "django_admin_log" VALUES (343,'16','Alex',2,'[{"changed": {"fields": ["Staff status", "Superuser status"]}}]',4,1,'2025-01-09 08:42:42.083233');
INSERT INTO "django_admin_log" VALUES (344,'3','Porche',1,'[{"added": {}}]',21,16,'2025-01-09 08:43:44.726711');
INSERT INTO "django_admin_log" VALUES (345,'8','Axio',1,'[{"added": {}}]',12,16,'2025-01-09 08:47:44.597082');
INSERT INTO "django_admin_log" VALUES (346,'10','KAA 123A',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (24)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (25)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (26)"}}]',13,16,'2025-01-09 08:49:48.918844');
INSERT INTO "django_admin_log" VALUES (347,'17','Stephen',1,'[{"added": {}}]',4,1,'2025-01-09 09:14:37.819093');
INSERT INTO "django_admin_log" VALUES (348,'17','Stephen',2,'[{"changed": {"fields": ["First name", "Last name", "Email address", "Staff status", "Superuser status", "Groups"]}}]',4,1,'2025-01-09 09:15:14.557030');
INSERT INTO "django_admin_log" VALUES (349,'4','Hatchback',2,'[]',9,16,'2025-01-09 09:43:09.196491');
INSERT INTO "django_admin_log" VALUES (350,'4','Hatchback',3,'',9,16,'2025-01-09 09:43:41.530798');
INSERT INTO "django_admin_log" VALUES (351,'6','Subaru',1,'[{"added": {}}]',11,16,'2025-01-09 09:44:57.830504');
INSERT INTO "django_admin_log" VALUES (352,'1','Prius',2,'[{"changed": {"fields": ["Name"]}}]',12,16,'2025-01-09 13:18:11.206493');
INSERT INTO "django_admin_log" VALUES (353,'11','KDE 740N',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (27)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (28)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (29)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (30)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (31)"}}]',13,16,'2025-01-09 13:28:33.598799');
INSERT INTO "django_admin_log" VALUES (354,'1','Harrier',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-09 13:42:14.037250');
INSERT INTO "django_admin_log" VALUES (355,'1','2016',2,'[{"changed": {"fields": ["Year"]}}]',8,1,'2025-01-09 13:42:39.172471');
INSERT INTO "django_admin_log" VALUES (356,'12','KDM 749F',1,'[{"added": {}}]',13,1,'2025-01-09 13:53:46.639203');
INSERT INTO "django_admin_log" VALUES (357,'12','KDM 749F',2,'[]',13,1,'2025-01-09 13:54:06.871041');
INSERT INTO "django_admin_log" VALUES (358,'12','KDM 749F',2,'[{"added": {"name": "vehicle image", "object": "VehicleImage object (32)"}}]',13,16,'2025-01-09 14:09:49.382741');
INSERT INTO "django_admin_log" VALUES (359,'12','KDM 749F',2,'[{"changed": {"fields": ["File"]}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (33)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (34)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (35)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (36)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (37)"}}]',13,16,'2025-01-09 14:12:06.392888');
INSERT INTO "django_admin_log" VALUES (360,'9','Prius',1,'[{"added": {}}]',12,16,'2025-01-09 14:16:34.351811');
INSERT INTO "django_admin_log" VALUES (361,'11','KDE 740N',2,'[{"changed": {"fields": ["Model"]}}]',13,16,'2025-01-09 14:16:43.084873');
INSERT INTO "django_admin_log" VALUES (362,'1','Landcruiser',2,'[{"changed": {"fields": ["Name"]}}]',12,16,'2025-01-10 08:56:25.749935');
INSERT INTO "django_admin_log" VALUES (363,'1','Land cruiser prado',2,'[{"changed": {"fields": ["Name"]}}]',12,16,'2025-01-10 09:04:00.727161');
INSERT INTO "django_admin_log" VALUES (364,'13','KBX 722B',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (38)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (39)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (40)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (41)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (42)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (43)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (44)"}}]',13,16,'2025-01-10 09:25:47.204361');
INSERT INTO "django_admin_log" VALUES (365,'13','KBX 722B',2,'[{"changed": {"fields": ["YOM", "Mileage"]}}]',13,16,'2025-01-10 09:33:28.614110');
INSERT INTO "django_admin_log" VALUES (366,'54','KDR 100B C200 in Auction c51ca1dd',3,'',18,1,'2025-01-10 13:40:14.362372');
INSERT INTO "django_admin_log" VALUES (367,'96',' Bid for KBX 722B by mbogo at Ksh 2900000',3,'',14,1,'2025-01-10 13:40:23.817031');
INSERT INTO "django_admin_log" VALUES (368,'95',' Bid for KDM 749F by Stephen at Ksh 1200000',3,'',14,1,'2025-01-10 13:40:23.894393');
INSERT INTO "django_admin_log" VALUES (369,'94',' Bid for KDM 749F by Alex at Ksh 2300000',3,'',14,1,'2025-01-10 13:40:23.941223');
INSERT INTO "django_admin_log" VALUES (370,'93',' Bid for KAA 123A by Stephen at Ksh 800000',3,'',14,1,'2025-01-10 13:40:24.019746');
INSERT INTO "django_admin_log" VALUES (371,'92',' Bid for KDS 001A by mbogo at Ksh 2500000',3,'',14,1,'2025-01-10 13:40:24.066228');
INSERT INTO "django_admin_log" VALUES (372,'8','KDR 023W',3,'',13,1,'2025-01-10 13:41:12.810711');
INSERT INTO "django_admin_log" VALUES (373,'6','KDR 100B',3,'',13,1,'2025-01-10 13:41:12.857452');
INSERT INTO "django_admin_log" VALUES (374,'9','KDS 001A',3,'',13,1,'2025-01-10 13:41:35.295758');
INSERT INTO "django_admin_log" VALUES (375,'12','KDM 749F',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,1,'2025-01-10 13:41:45.153966');
INSERT INTO "django_admin_log" VALUES (376,'6','walteragango@gmail.com',1,'[{"added": {}}]',20,1,'2025-01-10 14:09:20.953562');
INSERT INTO "django_admin_log" VALUES (377,'30','Auction 291bce73-051d-4007-af91-bded8c85f037',1,'[{"added": {}}]',15,14,'2025-01-10 14:22:53.502314');
INSERT INTO "django_admin_log" VALUES (378,'58','KBX 722B Land cruiser prado in Auction 291bce73',3,'',18,14,'2025-01-10 14:27:37.946486');
INSERT INTO "django_admin_log" VALUES (379,'57','KDM 749F Land cruiser prado in Auction 291bce73',3,'',18,14,'2025-01-10 14:27:37.977733');
INSERT INTO "django_admin_log" VALUES (380,'56','KDE 740N Prius in Auction 291bce73',3,'',18,14,'2025-01-10 14:27:37.993356');
INSERT INTO "django_admin_log" VALUES (381,'55','KAA 123A Axio in Auction 291bce73',3,'',18,14,'2025-01-10 14:27:38.008982');
INSERT INTO "django_admin_log" VALUES (382,'30','Auction 291bce73-051d-4007-af91-bded8c85f037',3,'',15,14,'2025-01-10 14:27:50.218906');
INSERT INTO "django_admin_log" VALUES (383,'31','Auction 4a33d02b-dd7d-4f9c-b3de-0956cb03b146',1,'[{"added": {}}]',15,14,'2025-01-10 14:29:58.174867');
INSERT INTO "django_admin_log" VALUES (384,'62','KBX 722B Land cruiser prado in Auction 4a33d02b',3,'',18,1,'2025-01-11 07:53:02.691030');
INSERT INTO "django_admin_log" VALUES (385,'61','KDM 749F Land cruiser prado in Auction 4a33d02b',3,'',18,1,'2025-01-11 07:53:02.691030');
INSERT INTO "django_admin_log" VALUES (386,'60','KDE 740N Prius in Auction 4a33d02b',3,'',18,1,'2025-01-11 07:53:02.691030');
INSERT INTO "django_admin_log" VALUES (387,'59','KAA 123A Axio in Auction 4a33d02b',3,'',18,1,'2025-01-11 07:53:02.706654');
INSERT INTO "django_admin_log" VALUES (388,'105',' Bid for KBX 722B by Stephen at Ksh 1000000',3,'',14,1,'2025-01-11 07:53:09.989254');
INSERT INTO "django_admin_log" VALUES (389,'104',' Bid for KDE 740N by mbogo at Ksh 800000',3,'',14,1,'2025-01-11 07:53:10.004886');
INSERT INTO "django_admin_log" VALUES (390,'103',' Bid for KDE 740N by Alex at Ksh 750000',3,'',14,1,'2025-01-11 07:53:10.004886');
INSERT INTO "django_admin_log" VALUES (391,'102',' Bid for KDM 749F by Alex at Ksh 280000',3,'',14,1,'2025-01-11 07:53:10.020505');
INSERT INTO "django_admin_log" VALUES (392,'101',' Bid for KDM 749F by walter at Ksh 6000000',3,'',14,1,'2025-01-11 07:53:10.020505');
INSERT INTO "django_admin_log" VALUES (393,'100',' Bid for KAA 123A by Alex at Ksh 1300000',3,'',14,1,'2025-01-11 07:53:10.020505');
INSERT INTO "django_admin_log" VALUES (394,'99',' Bid for KDE 740N by walter at Ksh 1400000',3,'',14,1,'2025-01-11 07:53:10.036133');
INSERT INTO "django_admin_log" VALUES (395,'98',' Bid for KAA 123A by mbogo at Ksh 5821485',3,'',14,1,'2025-01-11 07:53:10.036133');
INSERT INTO "django_admin_log" VALUES (396,'97',' Bid for KAA 123A by walter at Ksh 1600000',3,'',14,1,'2025-01-11 07:53:10.051762');
INSERT INTO "django_admin_log" VALUES (397,'7','Angela',3,'',4,1,'2025-01-11 08:36:06.990047');
INSERT INTO "django_admin_log" VALUES (398,'31','Auction 4a33d02b-dd7d-4f9c-b3de-0956cb03b146',3,'',15,1,'2025-01-11 08:37:40.465290');
INSERT INTO "django_admin_log" VALUES (399,'29','Auction c51ca1dd-671f-434a-803b-6f825bd6ec4b',3,'',15,1,'2025-01-11 08:37:40.480896');
INSERT INTO "django_admin_log" VALUES (400,'7','autobid@riverlong.com',1,'[{"added": {}}]',20,1,'2025-01-11 08:46:57.578910');
INSERT INTO "django_admin_log" VALUES (401,'1','mbogomartin25@gmail.com',3,'',20,1,'2025-01-11 08:47:04.686040');
INSERT INTO "django_admin_log" VALUES (402,'6','walteragango@gmail.com',3,'',20,1,'2025-01-11 08:57:44.182955');
INSERT INTO "django_admin_log" VALUES (403,'5','mmburu@riverlong.com',3,'',20,1,'2025-01-11 08:57:44.182955');
INSERT INTO "django_admin_log" VALUES (404,'32','Auction cba99b6f-bca4-451f-9cc4-984c75713596',1,'[{"added": {}}]',15,1,'2025-01-11 08:59:38.145431');
INSERT INTO "django_admin_log" VALUES (405,'66','KBX 722B Land cruiser prado in Auction cba99b6f',3,'',18,1,'2025-01-13 12:15:11.954244');
INSERT INTO "django_admin_log" VALUES (406,'65','KDM 749F Land cruiser prado in Auction cba99b6f',3,'',18,1,'2025-01-13 12:15:11.956561');
INSERT INTO "django_admin_log" VALUES (407,'64','KDE 740N Prius in Auction cba99b6f',3,'',18,1,'2025-01-13 12:15:11.967083');
INSERT INTO "django_admin_log" VALUES (408,'63','KAA 123A Axio in Auction cba99b6f',3,'',18,1,'2025-01-13 12:15:11.971616');
INSERT INTO "django_admin_log" VALUES (409,'121',' Bid for KBX 722B by Alex at Ksh 3230000',3,'',14,1,'2025-01-13 12:15:28.212117');
INSERT INTO "django_admin_log" VALUES (410,'120',' Bid for KDE 740N by Essy at Ksh 805000',3,'',14,1,'2025-01-13 12:15:28.243689');
INSERT INTO "django_admin_log" VALUES (411,'119',' Bid for KDE 740N by Stephen at Ksh 1000000',3,'',14,1,'2025-01-13 12:15:28.265325');
INSERT INTO "django_admin_log" VALUES (412,'118',' Bid for KBX 722B by Essy at Ksh 2900009',3,'',14,1,'2025-01-13 12:15:28.296845');
INSERT INTO "django_admin_log" VALUES (413,'117',' Bid for KDM 749F by Alex at Ksh 2900000',3,'',14,1,'2025-01-13 12:15:28.307848');
INSERT INTO "django_admin_log" VALUES (414,'116',' Bid for KAA 123A by walter at Ksh 1600000',3,'',14,1,'2025-01-13 12:15:28.321508');
INSERT INTO "django_admin_log" VALUES (415,'115',' Bid for KDE 740N by Alex at Ksh 1000000',3,'',14,1,'2025-01-13 12:15:28.337210');
INSERT INTO "django_admin_log" VALUES (416,'114',' Bid for KAA 123A by mbogo at Ksh 1500001',3,'',14,1,'2025-01-13 12:15:28.368409');
INSERT INTO "django_admin_log" VALUES (417,'113',' Bid for KDM 749F by Essy at Ksh 275900',3,'',14,1,'2025-01-13 12:15:28.384618');
INSERT INTO "django_admin_log" VALUES (418,'112',' Bid for KAA 123A by Stephen at Ksh 1000000',3,'',14,1,'2025-01-13 12:15:28.398247');
INSERT INTO "django_admin_log" VALUES (419,'111',' Bid for KAA 123A by Alex at Ksh 2000000',3,'',14,1,'2025-01-13 12:15:28.407298');
INSERT INTO "django_admin_log" VALUES (420,'110',' Bid for KDE 740N by mbogo at Ksh 1000000',3,'',14,1,'2025-01-13 12:15:28.417246');
INSERT INTO "django_admin_log" VALUES (421,'109',' Bid for KBX 722B by mbogo at Ksh 1200000',3,'',14,1,'2025-01-13 12:15:28.426245');
INSERT INTO "django_admin_log" VALUES (422,'108',' Bid for KAA 123A by Essy at Ksh 1525000',3,'',14,1,'2025-01-13 12:15:28.436776');
INSERT INTO "django_admin_log" VALUES (423,'107',' Bid for KDM 749F by Kage at Ksh 5',3,'',14,1,'2025-01-13 12:15:28.447771');
INSERT INTO "django_admin_log" VALUES (424,'106',' Bid for KDM 749F by Stephen at Ksh 10',3,'',14,1,'2025-01-13 12:15:28.454842');
INSERT INTO "django_admin_log" VALUES (425,'1','Land cruiser V8',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-13 13:02:50.823860');
INSERT INTO "django_admin_log" VALUES (426,'10','DYNA',1,'[{"added": {}}]',12,1,'2025-01-13 13:14:20.126200');
INSERT INTO "django_admin_log" VALUES (427,'10','Dyna',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-13 13:14:42.849730');
INSERT INTO "django_admin_log" VALUES (428,'10','Toyota Dyna',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-13 13:34:30.245173');
INSERT INTO "django_admin_log" VALUES (429,'1','2013',2,'[{"changed": {"fields": ["Year"]}}]',8,1,'2025-01-13 13:34:54.976991');
INSERT INTO "django_admin_log" VALUES (430,'5','Track',1,'[{"added": {}}]',9,1,'2025-01-13 13:50:55.821067');
INSERT INTO "django_admin_log" VALUES (431,'14','KCZ 023U',1,'[{"added": {}}]',13,1,'2025-01-13 13:51:05.117944');
INSERT INTO "django_admin_log" VALUES (432,'11','Allion ZZT240',1,'[{"added": {}}]',12,1,'2025-01-13 14:09:41.479741');
INSERT INTO "django_admin_log" VALUES (433,'11','Toyota Allion ZZT240',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-13 14:10:21.626891');
INSERT INTO "django_admin_log" VALUES (434,'4','2002',1,'[{"added": {}}]',8,1,'2025-01-13 14:10:46.677148');
INSERT INTO "django_admin_log" VALUES (435,'6','Sedan',1,'[{"added": {}}]',9,1,'2025-01-13 14:20:12.460370');
INSERT INTO "django_admin_log" VALUES (436,'15','KBH 851W',1,'[{"added": {}}]',13,1,'2025-01-13 14:21:53.031275');
INSERT INTO "django_admin_log" VALUES (437,'14','KCZ 023U',2,'[{"changed": {"fields": ["File"]}}]',13,1,'2025-01-13 14:49:46.860174');
INSERT INTO "django_admin_log" VALUES (438,'12','SUBARU OUTBACK BRM',1,'[{"added": {}}]',12,1,'2025-01-13 14:56:39.273161');
INSERT INTO "django_admin_log" VALUES (439,'12','Subaru Outback BRM',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-13 14:57:29.853119');
INSERT INTO "django_admin_log" VALUES (440,'7','suv',1,'[{"added": {}}]',9,1,'2025-01-13 15:00:49.186236');
INSERT INTO "django_admin_log" VALUES (441,'16','KCT 988K',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (45)"}}]',13,1,'2025-01-13 15:10:00.344982');
INSERT INTO "django_admin_log" VALUES (442,'13','ISUZU D-MAX TFR86',1,'[{"added": {}}]',12,1,'2025-01-13 15:39:41.643502');
INSERT INTO "django_admin_log" VALUES (443,'7','ISUZU',1,'[{"added": {}}]',11,1,'2025-01-13 15:40:04.867965');
INSERT INTO "django_admin_log" VALUES (444,'5','2018',1,'[{"added": {}}]',8,1,'2025-01-13 15:42:37.518758');
INSERT INTO "django_admin_log" VALUES (445,'8','Cover Body',1,'[{"added": {}}]',9,1,'2025-01-13 15:45:47.191405');
INSERT INTO "django_admin_log" VALUES (446,'17','KCS 939J',1,'[{"added": {}}]',13,1,'2025-01-13 16:08:41.073993');
INSERT INTO "django_admin_log" VALUES (447,'14','TOYOTA LANDCRUISER PRADO GRG120W',1,'[{"added": {}}]',12,1,'2025-01-13 16:22:12.874350');
INSERT INTO "django_admin_log" VALUES (448,'6','2006',1,'[{"added": {}}]',8,1,'2025-01-13 16:22:45.467973');
INSERT INTO "django_admin_log" VALUES (449,'14','Toyota Land Cruiser Prado GRG120W',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-13 16:28:31.412528');
INSERT INTO "django_admin_log" VALUES (450,'15','Toyota Harrier GSU30W',1,'[{"added": {}}]',12,1,'2025-01-13 16:43:25.337384');
INSERT INTO "django_admin_log" VALUES (451,'18','KBX 842W',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (46)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (47)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (48)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (49)"}}]',13,1,'2025-01-13 16:47:03.325194');
INSERT INTO "django_admin_log" VALUES (452,'16','Subaru Outback BS9',1,'[{"added": {}}]',12,1,'2025-01-13 16:54:27.388992');
INSERT INTO "django_admin_log" VALUES (453,'7','2016',1,'[{"added": {}}]',8,1,'2025-01-13 16:54:34.886545');
INSERT INTO "django_admin_log" VALUES (454,'19','KDN 730N',1,'[{"added": {}}]',13,1,'2025-01-13 17:03:52.413659');
INSERT INTO "django_admin_log" VALUES (455,'17','Mitsubishi Outlander CW4W',1,'[{"added": {}}]',12,1,'2025-01-13 17:09:02.202727');
INSERT INTO "django_admin_log" VALUES (456,'8','Mitsubishi',1,'[{"added": {}}]',11,1,'2025-01-13 17:09:20.872350');
INSERT INTO "django_admin_log" VALUES (457,'8','2010',1,'[{"added": {}}]',8,1,'2025-01-13 17:09:33.283565');
INSERT INTO "django_admin_log" VALUES (458,'20','KCN 782T',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (50)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (51)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (52)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (53)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (54)"}}]',13,1,'2025-01-13 17:13:26.230823');
INSERT INTO "django_admin_log" VALUES (459,'14','KCZ 023U',2,'[{"changed": {"fields": ["File"]}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (55)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (56)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (57)"}}]',13,16,'2025-01-14 05:01:08.600436');
INSERT INTO "django_admin_log" VALUES (460,'15','KBH 851W',2,'[{"changed": {"fields": ["File"]}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (58)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (59)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (60)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (61)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (62)"}}]',13,16,'2025-01-14 05:12:48.362199');
INSERT INTO "django_admin_log" VALUES (461,'17','KCS 939J',2,'[{"changed": {"fields": ["File"]}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (63)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (64)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (65)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (66)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (67)"}}]',13,16,'2025-01-14 05:36:26.247988');
INSERT INTO "django_admin_log" VALUES (462,'12','KDM 749F',3,'',13,1,'2025-01-14 05:41:53.425235');
INSERT INTO "django_admin_log" VALUES (463,'11','KDE 740N',3,'',13,1,'2025-01-14 05:41:53.443871');
INSERT INTO "django_admin_log" VALUES (464,'10','KAA 123A',3,'',13,1,'2025-01-14 05:41:53.457870');
INSERT INTO "django_admin_log" VALUES (465,'19','KDN 730N',2,'[{"changed": {"fields": ["File"]}}]',13,16,'2025-01-14 06:05:17.263192');
INSERT INTO "django_admin_log" VALUES (466,'2','2006',2,'[{"changed": {"fields": ["Year"]}}]',8,16,'2025-01-14 06:15:20.081292');
INSERT INTO "django_admin_log" VALUES (467,'13','KBX 722B',2,'[]',13,16,'2025-01-14 06:16:29.190556');
INSERT INTO "django_admin_log" VALUES (468,'13','KBX 722B',2,'[{"changed": {"fields": ["Reserve price"]}}]',13,16,'2025-01-14 06:19:19.763021');
INSERT INTO "django_admin_log" VALUES (469,'13','KBX 722B',2,'[]',13,1,'2025-01-14 06:19:20.579923');
INSERT INTO "django_admin_log" VALUES (470,'19','KDN 730N',2,'[{"added": {"name": "vehicle image", "object": "VehicleImage object (68)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (69)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (70)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (71)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (72)"}}]',13,16,'2025-01-14 06:32:06.064620');
INSERT INTO "django_admin_log" VALUES (471,'13','KBX 722B',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,1,'2025-01-14 07:01:22.518845');
INSERT INTO "django_admin_log" VALUES (472,'18','Prado J120',1,'[{"added": {}}]',12,14,'2025-01-14 07:50:26.021094');
INSERT INTO "django_admin_log" VALUES (473,'13','KBX 722B',2,'[{"changed": {"fields": ["Model"]}}]',13,14,'2025-01-14 07:50:48.783614');
INSERT INTO "django_admin_log" VALUES (474,'19','Land Cruiser Prado GRG120W',1,'[{"added": {}}]',12,1,'2025-01-14 07:55:28.608863');
INSERT INTO "django_admin_log" VALUES (475,'13','KBX 722B',2,'[{"changed": {"fields": ["Model"]}}]',13,1,'2025-01-14 07:55:37.513304');
INSERT INTO "django_admin_log" VALUES (476,'14','KCZ 023U',2,'[{"changed": {"fields": ["Is hotsale"]}}]',13,1,'2025-01-14 08:11:37.121181');
INSERT INTO "django_admin_log" VALUES (477,'13','D-MAX TFR86',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-14 08:24:21.414094');
INSERT INTO "django_admin_log" VALUES (478,'17','KCS 939J',2,'[]',13,1,'2025-01-14 08:33:10.048800');
INSERT INTO "django_admin_log" VALUES (479,'16','Outback BS9',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-14 08:33:30.788291');
INSERT INTO "django_admin_log" VALUES (480,'15','Harrier GSU30W',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-14 08:33:41.773427');
INSERT INTO "django_admin_log" VALUES (481,'14','Land Cruiser Prado GRG120W',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-14 08:33:49.629309');
INSERT INTO "django_admin_log" VALUES (482,'12','Outback BRM',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-14 08:33:58.345650');
INSERT INTO "django_admin_log" VALUES (483,'11','Allion ZZT240',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-14 08:34:40.703160');
INSERT INTO "django_admin_log" VALUES (484,'15','KBH 851W',2,'[]',13,1,'2025-01-14 08:34:46.454811');
INSERT INTO "django_admin_log" VALUES (485,'10','Dyna',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-14 08:35:14.703148');
INSERT INTO "django_admin_log" VALUES (486,'14','KCZ 023U',2,'[]',13,1,'2025-01-14 08:35:22.352724');
INSERT INTO "django_admin_log" VALUES (487,'17','Outlander CW4W',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-14 08:35:48.213116');
INSERT INTO "django_admin_log" VALUES (488,'20','KCN 782T',2,'[]',13,1,'2025-01-14 08:36:28.370898');
INSERT INTO "django_admin_log" VALUES (489,'17','KCS 939J',2,'[{"changed": {"name": "vehicle image", "object": "VehicleImage object (64)", "fields": ["Image"]}}]',13,1,'2025-01-14 12:10:14.336215');
INSERT INTO "django_admin_log" VALUES (490,'16','Alex',2,'[{"changed": {"fields": ["First name", "Last name", "Email address", "Groups"]}}]',4,1,'2025-01-14 13:17:18.706020');
INSERT INTO "django_admin_log" VALUES (491,'125',' Bid for KBX 722B by Alex at Ksh 1200001',3,'',14,1,'2025-01-14 13:18:25.552804');
INSERT INTO "django_admin_log" VALUES (492,'124',' Bid for KBX 722B by Alex at Ksh 1200000',3,'',14,1,'2025-01-14 13:18:25.568422');
INSERT INTO "django_admin_log" VALUES (493,'123',' Bid for KBX 722B by mbogo at Ksh 1100000',3,'',14,1,'2025-01-14 13:18:25.584050');
INSERT INTO "django_admin_log" VALUES (494,'122',' Bid for KCS 939J by Alex at Ksh 1600000',3,'',14,1,'2025-01-14 13:18:25.599673');
INSERT INTO "django_admin_log" VALUES (495,'11','john',3,'',4,1,'2025-01-14 13:23:07.709528');
INSERT INTO "django_admin_log" VALUES (496,'3','martin',3,'',4,1,'2025-01-14 13:23:07.725511');
INSERT INTO "django_admin_log" VALUES (497,'4','mbogo1',3,'',4,1,'2025-01-14 13:23:07.767985');
INSERT INTO "django_admin_log" VALUES (498,'6','mbogo111',3,'',4,1,'2025-01-14 13:23:07.820792');
INSERT INTO "django_admin_log" VALUES (499,'10','mbogomartin215@gmail.com',3,'',4,1,'2025-01-14 13:23:07.857152');
INSERT INTO "django_admin_log" VALUES (500,'12','test1',3,'',4,1,'2025-01-14 13:23:07.869590');
INSERT INTO "django_admin_log" VALUES (501,'8','tester',3,'',4,1,'2025-01-14 13:23:07.887591');
INSERT INTO "django_admin_log" VALUES (502,'2','Doeser',3,'',4,1,'2025-01-14 13:23:27.204736');
INSERT INTO "django_admin_log" VALUES (503,'13','KBX 722B',2,'[{"changed": {"fields": ["File"]}}]',13,1,'2025-01-15 05:39:41.530509');
INSERT INTO "django_admin_log" VALUES (504,'32','Auction cba99b6f-bca4-451f-9cc4-984c75713596',3,'',15,1,'2025-01-15 05:45:57.270143');
INSERT INTO "django_admin_log" VALUES (505,'13','KBX 722B',2,'[{"changed": {"fields": ["File"]}}]',13,1,'2025-01-15 05:47:03.087658');
INSERT INTO "django_admin_log" VALUES (506,'20','Wish',1,'[{"added": {}}]',12,1,'2025-01-15 06:09:45.385948');
INSERT INTO "django_admin_log" VALUES (507,'9','2003',1,'[{"added": {}}]',8,1,'2025-01-15 06:16:43.058761');
INSERT INTO "django_admin_log" VALUES (508,'20','Wish ZNE14G',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-15 06:19:58.486419');
INSERT INTO "django_admin_log" VALUES (509,'9','MPV',1,'[{"added": {}}]',9,1,'2025-01-15 06:27:37.028810');
INSERT INTO "django_admin_log" VALUES (510,'21','KBM 463A',1,'[{"added": {}}]',13,1,'2025-01-15 06:28:01.915044');
INSERT INTO "django_admin_log" VALUES (511,'21','KBM 463A',2,'[{"changed": {"fields": ["File"]}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (73)"}}]',13,16,'2025-01-15 06:43:55.615332');
INSERT INTO "django_admin_log" VALUES (512,'21','KBM 463A',2,'[{"added": {"name": "vehicle image", "object": "VehicleImage object (74)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (75)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (76)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (77)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (78)"}}]',13,16,'2025-01-15 07:30:38.895711');
INSERT INTO "django_admin_log" VALUES (513,'21','KBM 463A',2,'[]',13,1,'2025-01-15 07:32:52.640744');
INSERT INTO "django_admin_log" VALUES (514,'21','KBM 463A',2,'[{"changed": {"fields": ["File"]}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (79)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (80)"}}]',13,16,'2025-01-15 07:49:42.120557');
INSERT INTO "django_admin_log" VALUES (515,'16','KCT 988K',2,'[{"added": {"name": "vehicle image", "object": "VehicleImage object (81)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (82)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (83)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (84)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (85)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (86)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (87)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (88)"}}]',13,1,'2025-01-15 08:19:31.572796');
INSERT INTO "django_admin_log" VALUES (516,'3','Porche',3,'',21,1,'2025-01-15 10:17:37.794504');
INSERT INTO "django_admin_log" VALUES (517,'2','Test Financier',3,'',21,1,'2025-01-15 10:18:29.364099');
INSERT INTO "django_admin_log" VALUES (518,'21','Rush',1,'[{"added": {}}]',12,1,'2025-01-15 12:10:00.808174');
INSERT INTO "django_admin_log" VALUES (519,'22','KCF 657X',1,'[{"added": {}}]',13,1,'2025-01-15 12:19:26.189417');
INSERT INTO "django_admin_log" VALUES (520,'22','KCF 657X',2,'[{"changed": {"fields": ["File"]}}]',13,1,'2025-01-15 12:21:06.598517');
INSERT INTO "django_admin_log" VALUES (521,'19','KDN 730N',3,'',13,1,'2025-01-15 13:14:23.116889');
INSERT INTO "django_admin_log" VALUES (522,'22','Harrier ZSU60W',1,'[{"added": {}}]',12,1,'2025-01-15 15:00:25.531204');
INSERT INTO "django_admin_log" VALUES (523,'10','2014',1,'[{"added": {}}]',8,1,'2025-01-15 15:00:43.398494');
INSERT INTO "django_admin_log" VALUES (524,'23','KDE 005V',1,'[{"added": {}}]',13,1,'2025-01-15 15:04:11.359052');
INSERT INTO "django_admin_log" VALUES (525,'22','KCF 657X',2,'[{"changed": {"fields": ["Mileage"]}}]',13,1,'2025-01-15 15:29:08.261353');
INSERT INTO "django_admin_log" VALUES (526,'22','KCF 657X',2,'[{"added": {"name": "vehicle image", "object": "VehicleImage object (89)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (90)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (91)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (92)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (93)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (94)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (95)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (96)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (97)"}}]',13,1,'2025-01-15 15:32:03.877312');
INSERT INTO "django_admin_log" VALUES (527,'23','KDE 005V',2,'[{"changed": {"fields": ["Financier", "Mileage"]}}]',13,1,'2025-01-15 15:35:54.121016');
INSERT INTO "django_admin_log" VALUES (528,'23','Wagon',1,'[{"added": {}}]',12,1,'2025-01-15 16:03:49.706226');
INSERT INTO "django_admin_log" VALUES (529,'23','Toyota',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-15 16:09:10.209060');
INSERT INTO "django_admin_log" VALUES (530,'24','KDC 762A',1,'[{"added": {}}]',13,1,'2025-01-15 16:14:30.980553');
INSERT INTO "django_admin_log" VALUES (531,'24','KDC 762A',2,'[{"changed": {"fields": ["File"]}}]',13,16,'2025-01-15 21:28:50.342093');
INSERT INTO "django_admin_log" VALUES (532,'24','KDC 762A',2,'[{"changed": {"fields": ["Mileage"]}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (98)"}}]',13,16,'2025-01-16 02:08:58.122703');
INSERT INTO "django_admin_log" VALUES (533,'25','KCW 931Y',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (99)"}}]',13,16,'2025-01-16 02:16:26.197011');
INSERT INTO "django_admin_log" VALUES (534,'25','KCW 931Y',2,'[{"added": {"name": "vehicle image", "object": "VehicleImage object (100)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (101)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (102)"}}]',13,16,'2025-01-16 02:19:12.802235');
INSERT INTO "django_admin_log" VALUES (535,'24','X-Trail',1,'[{"added": {}}]',12,16,'2025-01-16 02:24:44.226889');
INSERT INTO "django_admin_log" VALUES (536,'26','KCZ 853F',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (103)"}}]',13,16,'2025-01-16 02:26:04.324151');
INSERT INTO "django_admin_log" VALUES (537,'27','KBR 056J',1,'[{"added": {}}]',13,16,'2025-01-16 03:30:03.379819');
INSERT INTO "django_admin_log" VALUES (538,'28','KBC 726O',1,'[{"added": {}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (104)"}}]',13,16,'2025-01-16 03:51:25.052994');
INSERT INTO "django_admin_log" VALUES (539,'28','KBC 726O',2,'[{"added": {"name": "vehicle image", "object": "VehicleImage object (105)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (106)"}}, {"added": {"name": "vehicle image", "object": "VehicleImage object (107)"}}]',13,16,'2025-01-16 03:55:12.465866');
INSERT INTO "django_admin_log" VALUES (540,'29','KBR 690K',1,'[{"added": {}}]',13,16,'2025-01-16 04:03:17.902063');
INSERT INTO "django_admin_log" VALUES (541,'29','KBR 690K',2,'[{"added": {"name": "vehicle image", "object": "VehicleImage object (108)"}}]',13,16,'2025-01-16 04:19:18.857849');
INSERT INTO "django_admin_log" VALUES (542,'30','KBH 518U',1,'[{"added": {}}]',13,16,'2025-01-16 04:30:12.374362');
INSERT INTO "django_admin_log" VALUES (543,'23','Probox',2,'[{"changed": {"fields": ["Name"]}}]',12,1,'2025-01-16 05:17:10.712506');
INSERT INTO "django_admin_log" VALUES (544,'25','KCW 931Y',2,'[]',13,1,'2025-01-16 05:30:41.661630');
INSERT INTO "django_admin_log" VALUES (545,'31','KDE 002C',1,'[{"added": {}}]',13,1,'2025-01-16 05:49:28.139544');
INSERT INTO "django_content_type" VALUES (1,'admin','logentry');
INSERT INTO "django_content_type" VALUES (2,'auth','permission');
INSERT INTO "django_content_type" VALUES (3,'auth','group');
INSERT INTO "django_content_type" VALUES (4,'auth','user');
INSERT INTO "django_content_type" VALUES (5,'contenttypes','contenttype');
INSERT INTO "django_content_type" VALUES (6,'sessions','session');
INSERT INTO "django_content_type" VALUES (7,'vehicles','fueltype');
INSERT INTO "django_content_type" VALUES (8,'vehicles','manufactureyear');
INSERT INTO "django_content_type" VALUES (9,'vehicles','vehiclebody');
INSERT INTO "django_content_type" VALUES (10,'vehicles','vehicleimage');
INSERT INTO "django_content_type" VALUES (11,'vehicles','vehiclemake');
INSERT INTO "django_content_type" VALUES (12,'vehicles','vehiclemodel');
INSERT INTO "django_content_type" VALUES (13,'vehicles','vehicle');
INSERT INTO "django_content_type" VALUES (14,'vehicles','bidding');
INSERT INTO "django_content_type" VALUES (15,'vehicles','auction');
INSERT INTO "django_content_type" VALUES (16,'vehicles','vehicleview');
INSERT INTO "django_content_type" VALUES (17,'users','profile');
INSERT INTO "django_content_type" VALUES (18,'vehicles','auctionhistory');
INSERT INTO "django_content_type" VALUES (19,'users','location');
INSERT INTO "django_content_type" VALUES (20,'vehicles','notificationrecipient');
INSERT INTO "django_content_type" VALUES (21,'vehicles','financier');
INSERT INTO "django_content_type" VALUES (22,'vehicles','yard');
INSERT INTO "django_migrations" VALUES (1,'contenttypes','0001_initial','2024-07-28 05:17:58.997421');
INSERT INTO "django_migrations" VALUES (2,'auth','0001_initial','2024-07-28 05:17:59.471407');
INSERT INTO "django_migrations" VALUES (3,'admin','0001_initial','2024-07-28 05:18:00.428119');
INSERT INTO "django_migrations" VALUES (4,'admin','0002_logentry_remove_auto_add','2024-07-28 05:18:00.782603');
INSERT INTO "django_migrations" VALUES (5,'admin','0003_logentry_add_action_flag_choices','2024-07-28 05:18:01.112253');
INSERT INTO "django_migrations" VALUES (6,'contenttypes','0002_remove_content_type_name','2024-07-28 05:18:01.497676');
INSERT INTO "django_migrations" VALUES (7,'auth','0002_alter_permission_name_max_length','2024-07-28 05:18:01.774084');
INSERT INTO "django_migrations" VALUES (8,'auth','0003_alter_user_email_max_length','2024-07-28 05:18:01.987545');
INSERT INTO "django_migrations" VALUES (9,'auth','0004_alter_user_username_opts','2024-07-28 05:18:02.161491');
INSERT INTO "django_migrations" VALUES (10,'auth','0005_alter_user_last_login_null','2024-07-28 05:18:02.348445');
INSERT INTO "django_migrations" VALUES (11,'auth','0006_require_contenttypes_0002','2024-07-28 05:18:02.509394');
INSERT INTO "django_migrations" VALUES (12,'auth','0007_alter_validators_add_error_messages','2024-07-28 05:18:02.702050');
INSERT INTO "django_migrations" VALUES (13,'auth','0008_alter_user_username_max_length','2024-07-28 05:18:03.164355');
INSERT INTO "django_migrations" VALUES (14,'auth','0009_alter_user_last_name_max_length','2024-07-28 05:18:03.407764');
INSERT INTO "django_migrations" VALUES (15,'auth','0010_alter_group_name_max_length','2024-07-28 05:18:03.641993');
INSERT INTO "django_migrations" VALUES (16,'auth','0011_update_proxy_permissions','2024-07-28 05:18:03.916976');
INSERT INTO "django_migrations" VALUES (17,'auth','0012_alter_user_first_name_max_length','2024-07-28 05:18:04.405093');
INSERT INTO "django_migrations" VALUES (18,'sessions','0001_initial','2024-07-28 05:18:04.889188');
INSERT INTO "django_migrations" VALUES (19,'users','0001_initial','2024-07-28 05:18:05.117502');
INSERT INTO "django_migrations" VALUES (20,'users','0002_remove_profile_image_profile_id_number_and_more','2024-07-28 05:18:05.432613');
INSERT INTO "django_migrations" VALUES (21,'users','0003_remove_profile_id_number_remove_profile_phone_number','2024-07-28 05:18:05.796303');
INSERT INTO "django_migrations" VALUES (22,'users','0004_profile_id_number_profile_phone_number','2024-07-28 05:18:06.115272');
INSERT INTO "django_migrations" VALUES (23,'users','0005_profile_email','2024-07-28 05:18:06.566511');
INSERT INTO "django_migrations" VALUES (24,'users','0006_alter_profile_email','2024-07-28 05:18:07.088727');
INSERT INTO "django_migrations" VALUES (25,'users','0007_remove_profile_email','2024-07-28 05:18:07.390810');
INSERT INTO "django_migrations" VALUES (26,'users','0008_remove_profile_id_number_remove_profile_phone_number','2024-07-28 05:18:07.779227');
INSERT INTO "django_migrations" VALUES (27,'users','0009_profile_id_number_profile_phone_number','2024-07-28 05:18:08.217573');
INSERT INTO "django_migrations" VALUES (28,'users','0010_alter_profile_id_number_alter_profile_phone_number','2024-07-28 05:18:08.654473');
INSERT INTO "django_migrations" VALUES (29,'users','0011_alter_profile_id_number_alter_profile_phone_number','2024-07-28 05:18:08.927172');
INSERT INTO "django_migrations" VALUES (30,'users','0012_alter_profile_id_number_alter_profile_phone_number','2024-07-28 05:18:09.425383');
INSERT INTO "django_migrations" VALUES (31,'users','0013_alter_profile_id_number_alter_profile_phone_number','2024-07-28 05:18:09.866940');
INSERT INTO "django_migrations" VALUES (32,'vehicles','0001_initial','2024-07-28 05:18:10.386625');
INSERT INTO "django_migrations" VALUES (33,'vehicles','0002_remove_vehicle_created_by_remove_bid_user_and_more','2024-07-28 05:18:11.085039');
INSERT INTO "django_migrations" VALUES (34,'vehicles','0003_delete_customuser','2024-07-28 05:18:11.258469');
INSERT INTO "django_migrations" VALUES (35,'vehicles','0004_customuser','2024-07-28 05:18:11.764127');
INSERT INTO "django_migrations" VALUES (36,'vehicles','0005_alter_vehicle_bid_status_delete_customuser','2024-07-28 05:18:12.196757');
INSERT INTO "django_migrations" VALUES (37,'vehicles','0006_vehicle_file','2024-07-28 05:18:12.565813');
INSERT INTO "django_migrations" VALUES (38,'vehicles','0007_alter_vehicle_file','2024-07-28 05:18:12.849009');
INSERT INTO "django_migrations" VALUES (39,'vehicles','0008_alter_vehicle_file','2024-07-28 05:18:13.097138');
INSERT INTO "django_migrations" VALUES (40,'vehicles','0009_alter_vehicle_file','2024-07-28 05:18:13.399254');
INSERT INTO "django_migrations" VALUES (41,'vehicles','0010_alter_vehicle_file','2024-07-28 05:18:13.767518');
INSERT INTO "django_migrations" VALUES (42,'vehicles','0011_bid_user','2024-07-28 05:18:14.098277');
INSERT INTO "django_migrations" VALUES (43,'vehicles','0012_rename_bid_bidding','2024-07-28 05:18:14.681598');
INSERT INTO "django_migrations" VALUES (44,'vehicles','0013_alter_bidding_vehicle_alter_vehicleimage_image','2024-07-28 05:18:15.146521');
INSERT INTO "django_migrations" VALUES (45,'vehicles','0014_auction','2024-07-28 05:18:15.653948');
INSERT INTO "django_migrations" VALUES (46,'vehicles','0015_vehicle_views_vehicleview','2024-07-28 05:18:16.275799');
INSERT INTO "django_migrations" VALUES (47,'vehicles','0016_vehicle_registration_no_vehicle_v_id','2024-07-28 05:28:49.124389');
INSERT INTO "django_migrations" VALUES (48,'vehicles','0017_auctionhistory','2024-08-08 05:01:43.569866');
INSERT INTO "django_migrations" VALUES (49,'vehicles','0018_auction_approved','2024-08-08 05:01:43.598733');
INSERT INTO "django_migrations" VALUES (50,'vehicles','0019_alter_vehicle_bid_status','2024-08-08 05:01:43.627068');
INSERT INTO "django_migrations" VALUES (51,'vehicles','0020_rename_bid_status_vehicle_status','2024-08-08 05:01:43.664078');
INSERT INTO "django_migrations" VALUES (52,'vehicles','0021_alter_auctionhistory_options_and_more','2024-08-08 05:01:43.734881');
INSERT INTO "django_migrations" VALUES (53,'vehicles','0022_auction_created_at','2024-08-08 05:01:43.770846');
INSERT INTO "django_migrations" VALUES (54,'vehicles','0023_auction_current_time_alter_auction_created_at','2024-08-08 05:01:43.805075');
INSERT INTO "django_migrations" VALUES (55,'vehicles','0024_remove_auction_current_time','2024-08-08 05:01:43.821623');
INSERT INTO "django_migrations" VALUES (56,'vehicles','0025_alter_auctionhistory_auction_and_more','2024-08-08 05:01:43.893162');
INSERT INTO "django_migrations" VALUES (57,'vehicles','0026_alter_auctionhistory_auction_and_more','2024-08-08 05:01:43.964659');
INSERT INTO "django_migrations" VALUES (58,'vehicles','0027_rename_sold_auctionhistory_on_bid_and_more','2024-08-08 05:01:43.999075');
INSERT INTO "django_migrations" VALUES (59,'vehicles','0028_vehicle_transmission','2024-08-08 05:01:44.023001');
INSERT INTO "django_migrations" VALUES (60,'vehicles','0029_alter_auctionhistory_auction_and_more','2024-08-12 09:52:16.844700');
INSERT INTO "django_migrations" VALUES (61,'vehicles','0030_alter_vehicle_status','2024-08-26 04:43:25.134836');
INSERT INTO "django_migrations" VALUES (62,'vehicles','0031_alter_vehicle_status','2024-08-26 04:44:38.979132');
INSERT INTO "django_migrations" VALUES (63,'vehicles','0032_vehicle_description','2024-08-26 05:12:43.774401');
INSERT INTO "django_migrations" VALUES (64,'users','0014_customuser','2024-08-28 15:47:50.124879');
INSERT INTO "django_migrations" VALUES (65,'users','0015_location_profile_location_delete_customuser','2024-08-28 15:47:50.218906');
INSERT INTO "django_migrations" VALUES (66,'vehicles','0033_auctionhistory_sold_alter_vehicle_status','2024-10-17 09:19:31.458539');
INSERT INTO "django_migrations" VALUES (67,'vehicles','0034_notificationrecipient','2024-10-24 07:03:07.787434');
INSERT INTO "django_migrations" VALUES (68,'users','0016_rename_id_number_profile_id_number','2024-10-26 10:36:29.710169');
INSERT INTO "django_migrations" VALUES (69,'vehicles','0035_vehicle_color_vehicle_seats','2024-10-26 10:36:29.741411');
INSERT INTO "django_migrations" VALUES (70,'vehicles','0036_financier_yard_vehicle_financier_vehicle_yard','2024-10-26 10:46:48.320149');
INSERT INTO "django_migrations" VALUES (71,'vehicles','0037_vehicle_approved_at_vehicle_approved_by_and_more','2024-11-10 11:26:35.182357');
INSERT INTO "django_migrations" VALUES (72,'vehicles','0038_vehicle_is_hotsale','2024-11-17 10:09:32.684545');
INSERT INTO "django_migrations" VALUES (73,'vehicles','0038_alter_vehicle_description','2024-11-17 17:36:55.663155');
INSERT INTO "django_migrations" VALUES (74,'vehicles','0039_vehicle_is_hotsale','2024-11-17 17:36:55.941780');
INSERT INTO "django_migrations" VALUES (75,'vehicles','0040_merge_0038_vehicle_is_hotsale_0039_vehicle_is_hotsale','2024-11-17 17:36:56.148305');
INSERT INTO "django_migrations" VALUES (76,'vehicles','0041_rename_created_at_bidding_bid_time_and_more','2025-01-14 12:35:40.634834');
INSERT INTO "django_session" VALUES ('ns54h9cdxyq87ytf56g0th8babr15btj','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1sXwqo:ssDgAvmaFfg2pe8MNeEn73wYOesdG6IEWg_ef9aVBDE','2024-08-11 05:53:46.285091');
INSERT INTO "django_session" VALUES ('v90u03byz5u1lwbxeu9rufducws6l3tc','.eJxVjEEOwiAQRe_C2hA60Iy4dO8ZyAwDUjU0Ke2q8e5K0oVu33v_7yrQtpawtbSESdRFgTr9Mqb4TLULeVC9zzrOdV0m1j3Rh236Nkt6XY_276BQK9_1AF4Me47O2QiQGMcslkkQwKPBBDCMCGfPLnuThTC6Tq1YEwmMen8A27Y3jg:1sXxYn:2WzNgG1xvatnl40ZUOHCHUh_Xl6cQfYrocDdNwslMPM','2024-08-11 06:39:13.044531');
INSERT INTO "django_session" VALUES ('pizd1b6kb1toi637p3p8354xy3as0ed7','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1sYNG3:fNCfHl40A6wWwni9Kw29rOgmxu1r7ZxZJm9vGyaOG1E','2024-08-12 10:05:35.046796');
INSERT INTO "django_session" VALUES ('92qsdyuivd9eqmykhoptjsucf4mbftpa','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1sYQtN:UBkDLhvRpqDXNNA5FO8XvKgXwM7eD3buCs0tpBMpIpQ','2024-08-12 13:58:25.800119');
INSERT INTO "django_session" VALUES ('5wimsjjm7uv7lkxcxfj3g3j34o4thhat','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1sYRlL:OyIUFJDRdGehiPPBg8CNS1mgKWVpE0QdAToUm1Emo0o','2024-08-12 14:54:11.307673');
INSERT INTO "django_session" VALUES ('5csab0340lqfcs6co6iesrz0eqiwl48d','.eJxVjLsOAiEURP-F2hAuz11Le7-BXLggqwaSZbcy_ruSbKHFNHPOzIt53Lfi955WvxA7M8dOv13A-Eh1ALpjvTUeW93WJfCh8IN2fm2UnpfD_Tso2MtYZwvWgiYhpQQDhBM6E0jqWSmjZIYQRXDfGJmcE1bpRGDMPIFSWSB7fwDApDbJ:1saKtB:mekUhN-7s44HgN9VDsQ0yO-0uqSX5gB-tFP61ky4Wgc','2024-08-17 19:58:05.533985');
INSERT INTO "django_session" VALUES ('r5os9z18rauf8f7wbe6jnhifg8tfk423','.eJxVjLsOAiEURP-F2hAuz11Le7-BXLggqwaSZbcy_ruSbKHFNHPOzIt53Lfi955WvxA7M8dOv13A-Eh1ALpjvTUeW93WJfCh8IN2fm2UnpfD_Tso2MtYZwvWgiYhpQQDhBM6E0jqWSmjZIYQRXDfGJmcE1bpRGDMPIFSWSB7fwDApDbJ:1sbDH1:ogSJeDiqx8TrI7IiQPwooQoy0I-Ui_PzU323YUwuXaE','2024-08-20 06:02:19.036602');
INSERT INTO "django_session" VALUES ('ch5q3z2iylu7wh77jgjk6yz05a65p7oh','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1sc2mx:0lrVQVyAOIaulNoJRQnVQ-sPXjh8h4NhbnTRF4xacPg','2024-08-22 13:02:43.291847');
INSERT INTO "django_session" VALUES ('5zxt99h8pqrd0nuuidr76yy4lyjlfwsi','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1sciAN:_VO2-EcI9_n7KTSSy2KokiUEPohOkjdJgANO5RNrHiY','2024-08-24 09:13:39.495782');
INSERT INTO "django_session" VALUES ('gnl0fi1thjcl1g8rmveq6olqjv8skn2z','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1sdQsZ:dQJHG9MpUEKsOj7qQcI04TDf3Vre3KOQFhnTdx4vWnM','2024-08-26 08:58:15.305006');
INSERT INTO "django_session" VALUES ('0ssn9kcrqfquugcswood1p8buspzik5m','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1sdSuf:Asp2THLFQkx87yZUTBTgJU5Wz9d7eMTTuLuuYJ-dmWA','2024-08-26 11:08:33.462392');
INSERT INTO "django_session" VALUES ('kkty03lp5sm85iw94hwzj1gn17d5yo4i','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1sdiPk:QwcN369Mje6Tss5AZGAAdDwxgzy5IzTKzcBJETCNJhw','2024-08-27 03:41:40.654287');
INSERT INTO "django_session" VALUES ('dgixhh8yoznj6aad4ep4j4gek3ugvmf5','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1sfzCs:BwqQKVYYRzECj9uLtrdrAkqID6OkKW6SuzgZTDlFxrg','2024-09-02 10:01:46.614883');
INSERT INTO "django_session" VALUES ('mreizbfu4nsca5misutto9fy8gkq5fu2','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1siRUe:K2eQgc5ERWKsydOc29pfAlK_DoxaGpeZg7IfgTnJBrE','2024-09-09 04:38:16.879867');
INSERT INTO "django_session" VALUES ('02539k9q8jyt393fk45zige8lc7vy3qi','.eJxVjMEOwiAQRP-FsyF0QVg8eu83kAW2UjU0Ke3J-O9K0oMeZ96beYlA-1bC3ngNcxYX4cXpt4uUHlw7yHeqt0WmpW7rHGVX5EGbHJfMz-vh_h0UauW7Rj_YFFM2BIrxDATZGkCvAfyEbKJFdj2YCTW7QRsVlSYVnfXZGSXeH8uYNsE:1sjL3Y:x3tBRbu9ukqPGuNwfm0-RJAuh3wmOly8U-n5Gxc7dVg','2024-09-11 15:58:00.471918');
INSERT INTO "django_session" VALUES ('eer0zuoddzqu61yrqax3ei8hvkacawgb','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1sjPE6:pOjr_EGWAWHonNoP-_UZummPXjDW21icN5HbKUvVLyo','2024-09-11 20:25:10.164726');
INSERT INTO "django_session" VALUES ('pbeauurym53qs9tcd1s5votg5l5arnd4','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1srezg:k2Ob4FpLjd64jqRL2Kz3wDucR1OApusOCS4vONfGBWw','2024-10-04 14:52:24.876100');
INSERT INTO "django_session" VALUES ('qatc09vuodj8k6o9aslo32hfw6dea12t','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1st5F8:H0BVxs59geZAQ7mpZrOF6Q51H7XVGf8GOYkICcjFJGk','2024-10-08 13:06:14.696824');
INSERT INTO "django_session" VALUES ('l4ebsebjo9trl7k9m1zh3pyo8o0aogrl','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1swZW6:V-1tIkNAn4yH3xmRIm3o-YuS50xBMDCPY8oUeE5hbDc','2024-10-18 04:02:10.231965');
INSERT INTO "django_session" VALUES ('t9fbpb2ztby7cr8ghf9mtwda4vs47c4u','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1synXV:YgK5dk7CLQjE8YN-rZvatmRVaA69nXG6jQzAnF3cUKU','2024-10-24 07:24:49.569974');
INSERT INTO "django_session" VALUES ('w77d8ymhsu9troc7kn37w4inzjsbi56h','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1szX4S:4FcRfCyeWNJ8e3ZhmfFnhngtXuQ7AX-MlsQ7fYXAuY4','2024-10-26 08:01:52.570173');
INSERT INTO "django_session" VALUES ('egmkyus7c2dl3yxxan81wwbtj6mmojor','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1t0m5T:q8E1aGePDhdX4u6lS1vRVLZyQrFA6smdAxdUmsS8Yu4','2024-10-29 18:16:03.956422');
INSERT INTO "django_session" VALUES ('bauzy1t35i2pm4fno7k5nb6jf4dgrh79','.eJxVjEEOgjAQRe_StWkoTNsZl-49QzPDFIsaSCisjHdXEha6_e-9_zKJt7WkreYljWrOpjOn3024f-RpB3rn6Tbbfp7WZRS7K_ag1V5nzc_L4f4dFK7lWwckZR-xCyJO2gYgiiABgmIPRC0GDOAhDl48qR86ZQeIxA1pVGfeH73cNuY:1t13S4:_cGPZV5iL87rkeDHTeicHyBxGrVR3v8pv-I8Aw3Lj5c','2024-10-30 12:48:32.518904');
INSERT INTO "django_session" VALUES ('gnvgpsmi35ojfv0g1qj3vznehk30qkbh','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1t1NG2:yZw3C1k5FRutMoDTk4u1DD-jrm7Mg0GJOwpAJLk7aew','2024-10-31 09:57:26.503749');
INSERT INTO "django_session" VALUES ('42wu4r0in6s8jmr6acr5k7ar94a9xget','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1t3r0F:vG2M74DvVfv5z3aeIAxNS7YAIRU1jzKU6vVYXdtJLZw','2024-11-07 06:07:23.575583');
INSERT INTO "django_session" VALUES ('ig46avbs217kh1fok3fyxk80ij93gblj','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1t3rBP:1yv4LwG31dO97oWrr0wyzOoqcMlNHI3r1UO_BJvJraI','2024-11-07 06:18:55.068108');
INSERT INTO "django_session" VALUES ('losn6rhhxnymvb7331otjqhp2z6rg2if','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1t3rGZ:UFOVjYiKo0sJPnQ-djzuhw5XM23IhdF82yJhy6cIME8','2024-11-07 06:24:15.476049');
INSERT INTO "django_session" VALUES ('8zk0ywybl9tpkctpvc59quma73081xoc','.eJxVjEEOwiAQRe_C2hA60Iy4dO8ZyAwDUjU0Ke2q8e5K0oVu33v_7yrQtpawtbSESdRFgTr9Mqb4TLULeVC9zzrOdV0m1j3Rh236Nkt6XY_276BQK9_1AF4Me47O2QiQGMcslkkQwKPBBDCMCGfPLnuThTC6Tq1YEwmMen8A27Y3jg:1t3rew:_o2Wnh8b0toF55zAzl0s9AfEsQM0JhMNS6tIZ7nahvk','2024-11-07 06:49:26.078460');
INSERT INTO "django_session" VALUES ('0vj0owtb3vaap2q73bryh588pkt3uka6','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1t3rts:UvNdYqWPJ1Jv7loqqd1ZJbr33OHLIXtEGHLAk0apxbE','2024-11-07 07:04:52.776295');
INSERT INTO "django_session" VALUES ('0q458eq4povr5c783550ygzshd8l3zu8','.eJxVjEEOwiAQRe_C2hA60Iy4dO8ZyAwDUjU0Ke2q8e5K0oVu33v_7yrQtpawtbSESdRFgTr9Mqb4TLULeVC9zzrOdV0m1j3Rh236Nkt6XY_276BQK9_1AF4Me47O2QiQGMcslkkQwKPBBDCMCGfPLnuThTC6Tq1YEwmMen8A27Y3jg:1t67S6:nBdjyuviBnsQzAiZiinbwHl6cQFQ_LkVBOsaPQ1xtW4','2024-11-13 12:05:30.422943');
INSERT INTO "django_session" VALUES ('o6vf3sinafy11fbx3srl8gp5zubjfbeq','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1t7VDM:t5-xNwByvZviYwqY_6FBl4f7fjAlCLnFFoHAVl92l0c','2024-11-17 07:40:00.025109');
INSERT INTO "django_session" VALUES ('bdnai74usv40byjp2rv09u2lbz89fh8w','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1t7ipl:x_LArTPM10Se0-TlhLxrBbuwm-BEjUkoyY9HBvQC-mo','2024-11-17 22:12:33.336054');
INSERT INTO "django_session" VALUES ('kxcujczmdh16chwgf8vic3wogallv6n1','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1t8yVb:BHoxTaNDJGuIQwwni0OCv5cr0Zpors0LOJhzxFb88lI','2024-11-21 09:08:55.792361');
INSERT INTO "django_session" VALUES ('8mu8oyoruar29aup9o4d0rdqf0km3jme','.eJxVjMEOwiAQRP-FsyF0QVg8eu83kAW2UjU0Ke3J-O9K0oMeZ96beYlA-1bC3ngNcxYX4cXpt4uUHlw7yHeqt0WmpW7rHGVX5EGbHJfMz-vh_h0UauW7Rj_YFFM2BIrxDATZGkCvAfyEbKJFdj2YCTW7QRsVlSYVnfXZGSXeH8uYNsE:1t93y8:w5TiIl7k6JJY-C7Q9KlHrxW1m46BZ5eGbX_Y-OA3ptM','2024-11-21 14:58:44.033411');
INSERT INTO "django_session" VALUES ('iaip9xvp9iyjnmdedd9wm443monxwpqa','.eJxVjEEOwiAQRe_C2hA60Iy4dO8ZyAwDUjU0Ke2q8e5K0oVu33v_7yrQtpawtbSESdRFgTr9Mqb4TLULeVC9zzrOdV0m1j3Rh236Nkt6XY_276BQK9_1AF4Me47O2QiQGMcslkkQwKPBBDCMCGfPLnuThTC6Tq1YEwmMen8A27Y3jg:1tA1BE:9_QBgUBnO98ZhCUXxs6ySiLISQuHp7UJVObO0HQmMBA','2024-11-24 06:12:12.058972');
INSERT INTO "django_session" VALUES ('1hxb1tajwzdpxxqzsi9yc75yxx0ruuil','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tA5BP:vPGT9xcgCHYQciR9PUmrOjqPqkuvjeXGIQXzIL_6vEY','2024-11-24 10:28:39.326792');
INSERT INTO "django_session" VALUES ('684uez3jcgwzvuziihik0smwejltcils','.eJxVjMEOwiAQRP-FsyF0QVg8eu83kAW2UjU0Ke3J-O9K0oMeZ96beYlA-1bC3ngNcxYX4cXpt4uUHlw7yHeqt0WmpW7rHGVX5EGbHJfMz-vh_h0UauW7Rj_YFFM2BIrxDATZGkCvAfyEbKJFdj2YCTW7QRsVlSYVnfXZGSXeH8uYNsE:1tCcEy:v3nwxSJexFbMecJH8dzfAag7aHG_mBCTmyapxDy4X70','2024-12-01 10:10:48.397174');
INSERT INTO "django_session" VALUES ('gjan59pmtci0vw77lm5h2t2tbn4smlg4','.eJxVjDEOwyAQBP9CHSEDB5iU6f0GdMARnEQgGbuK8vfYkouk2WJndt_M47YWv3Va_JzYlQnFLr9lwPikepD0wHpvPLa6LnPgh8JP2vnUEr1up_t3ULCXfa0iiZxBGWkNRksak3U6GBQg8hAActyTRnRSoAtgaJQwaI1RuiQ1sM8XEz03_A:1tCtXt:eml5i0d9tRbI53Kanqpg6r6x4a-3B-O9EojTtkmt6l0','2024-12-02 04:39:29.096932');
INSERT INTO "django_session" VALUES ('8c4de13e208ou1ouq998nf36m6uad21m','.eJxVjDEOwyAQBP9CHSEDB5iU6f0GdMARnEQgGbuK8vfYkouk2WJndt_M47YWv3Va_JzYlQnFLr9lwPikepD0wHpvPLa6LnPgh8JP2vnUEr1up_t3ULCXfa0iiZxBGWkNRksak3U6GBQg8hAActyTRnRSoAtgaJQwaI1RuiQ1sM8XEz03_A:1tCvId:gqeEE4H3YsB5vwzmxbiH8IoZDiriQ1LOozDf2eO3efk','2024-12-02 06:31:51.634088');
INSERT INTO "django_session" VALUES ('7er0qyisqxfgiqlb7cjqyxg9a1lchmyt','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tSc0u:ygDgxwYqeeQIHfr7LAf4cbf0ZAUExLw-qoHWoT3oPb8','2025-01-14 13:10:24.568880');
INSERT INTO "django_session" VALUES ('o8191rd2nlnqt98dlblmx10jaae1efiz','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tTHvb:m5zT3EyjjdBx2gv0XTqes3ifbQfkmdH-BMcmJ4SeJL0','2025-01-16 09:55:43.935910');
INSERT INTO "django_session" VALUES ('hf64aozi7dspia5km8vqih3ccn7shmy0','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tTc0u:Urzay6Fdh7WuKz4Nb28gDZ1rtyCS-F8JAGifN6IFbZg','2025-01-17 07:22:32.895738');
INSERT INTO "django_session" VALUES ('nxl5costrbb778ol7lqi763e7woeyykt','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tTc21:XL7MOCBV-xCm6jTiPDC_5je-BenvO1T9Y_4yAw5kDbU','2025-01-17 07:23:41.641845');
INSERT INTO "django_session" VALUES ('lcgagc2dzcqirlatxnpicymz46jn4ijv','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tTcIY:m42Gmd4gNNHiYdj11FRAnvFyXjeCgf8TTgDI3V2HHTc','2025-01-17 07:40:46.734010');
INSERT INTO "django_session" VALUES ('n49k2czp11zn12fcm23ro2azf0eeveya','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tTfQ7:_NuyitrLVMW37Cfo_Z6u4VS0q8ROykX9xMWHOamLifA','2025-01-17 11:00:47.465405');
INSERT INTO "django_session" VALUES ('lpzuuzptt0takm8dfgjrg92h5frod1r6','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tTfVR:MSdVpMl7KOl6H38eLJODO7fHZCaCBZnVQPypulevPqs','2025-01-17 11:06:17.390213');
INSERT INTO "django_session" VALUES ('x6zrlbc837drvdy36hur5mmyvpl0vsc9','.eJxVjEEOwiAQRe_C2hAQRjou3fcMBJhBqgaS0q6Md7dNutDtf-_9t_BhXYpfO89-InEV2orT7xhDenLdCT1CvTeZWl3mKcpdkQftcmzEr9vh_h2U0MtWgwVD0WTFF5vZOHZnRBjQAmWtkSAGm1hZiA6ywjSwzuiYM206MYrPFwYEOMM:1tTgBS:bWrQGx88i7wwTk2qT0LsRH4iI-PrhgsYuoyAKgxD8KA','2025-01-17 11:49:42.326441');
INSERT INTO "django_session" VALUES ('5i6v11k83i87g2pogjqpi7iirf9xkaq6','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tThz0:7v0xCBI_JwVrXRCuor9hAehSHxLdUvCRp-go-m1RhKs','2025-01-17 13:44:58.941215');
INSERT INTO "django_session" VALUES ('0zsjthxt855llbe5oejpypysqrwy9knr','.eJxVjEEOwiAQRe_C2hBqhwFcuvcMZAZGqRpISrsy3l2bdKHb_977LxVpXUpcu8xxyuqkBqsOvyNTekjdSL5TvTWdWl3mifWm6J12fWlZnufd_Tso1Mu3hmMAM8rVJ2QX2AOEbBMbTABeRrYGHVtO2YOgJ4EsOIbBMgIGJ6TeH_3YN_Y:1tTyVi:B2_vSsYf6jrpM5QPxFEnMsNVDl_WU4qX5GhlaCz-Gj0','2025-01-18 07:23:50.043896');
INSERT INTO "django_session" VALUES ('0xhgztmr8nn6lwxf1xfzz04y6bqml2y1','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tV2f0:V_QrjReW0TvmnoKWg0Z7tIIOtLzBy8cyimzlW9PoOrM','2025-01-21 06:01:50.433481');
INSERT INTO "django_session" VALUES ('98xsq257q01tbr9blvd3u3ovvhsr6l9a','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tVBn7:aAmjodt8KKKKL7F03leca5RXRCl9gICbxmwD_RCZw5k','2025-01-21 15:46:49.155490');
INSERT INTO "django_session" VALUES ('9s75n2a7bentiskd4lzmtnectd4egyyz','.eJxVjMsOwiAUBf-FtSGFlkt16b7fQO4DpGogKe3K-O_apAvdnpk5LxVwW3PYWlzCLOqijFen35GQH7HsRO5YblVzLesyk94VfdCmpyrxeT3cv4OMLX9rBmYBGR0xMVLnEnhPHg3Q4A35aMwQAXuS1AN2rrfAZ6bRWrEp2qTeHzq6ORg:1tVoeM:lI7Ccfi64u_baIL3fdhc1dVF2-Af6WtHYj1wAeDYFo4','2025-01-23 09:16:22.462949');
INSERT INTO "django_session" VALUES ('abuxr4pvsm0sfxtcz4jnzp5wg2464ie2','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tVsdH:1TsaFXdmIvRtRE2DDAozGguC6wPK43yT-_Rsrn1kbfA','2025-01-23 13:31:31.782163');
INSERT INTO "django_session" VALUES ('3kxib92ica4k6yj0yeg0o39k5kzvtu6w','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tW8M2:QPZwhCWZ3GgGS1AwGiEFUwjpjwixk0HYQhsuKWjQeIY','2025-01-24 06:18:46.576859');
INSERT INTO "django_session" VALUES ('1rh1co4sicoto1lyay9ujio7f27uy0rx','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tWBIl:STarcgXH9XLl49K4_sGfeAsHXfjTqQknoWaYEWWJVHQ','2025-01-24 09:27:35.959954');
INSERT INTO "django_session" VALUES ('ay71b97qfwzs51akyjtubs0ydbit99zn','.eJxVjEEOwiAQRe_C2hAQRjou3fcMBJhBqgaS0q6Md7dNutDtf-_9t_BhXYpfO89-InEV2orT7xhDenLdCT1CvTeZWl3mKcpdkQftcmzEr9vh_h2U0MtWgwVD0WTFF5vZOHZnRBjQAmWtkSAGm1hZiA6ywjSwzuiYM206MYrPFwYEOMM:1tWFpp:LpsFoGJucssnRylLWm5kMzOlW608gaKAvNSJJDthuaE','2025-01-24 14:18:01.818255');
INSERT INTO "django_session" VALUES ('a7327djl1sl350413cudp728cua54xyp','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tWG2c:PuwQ9XVv-lzMzDr_nyOqoWEzzktp6t9FXZtmd7MRx1A','2025-01-24 14:31:14.993768');
INSERT INTO "django_session" VALUES ('h8nagcgd4c9gatkosedzf8b3rin2oiqw','.eJxVjEEOwiAQRe_C2hAoZQCX7j0DmWGoVA1NSrsy3l1JutDte-__l4i4byXuLa9xZnEW2ovTLyRMj1y74TvW2yLTUrd1JtkTedgmrwvn5-Vo_w4KttLX3mkTpilbDSZZdkRKGUTHX4Qm8wADZDcS-jAGBMKgAQwqtmATg3h_ABv2OG8:1tWWyI:VBQofWDCC80-s58D10PiT0i6ZipSW6dOruM7RMaRjpU','2025-01-25 08:35:54.982877');
INSERT INTO "django_session" VALUES ('7ap19icqyk75l0ck0zak0itfwl0izwwx','.eJxVjMEOgjAQRP-lZ9NsW6CtR-98Q7PsbgU1JaFwMv67kHDQZE7z3sxbJdzWMW1VljSxuioT1eW3HJCeUg7CDyz3WdNc1mUa9KHok1bdzyyv2-n-HYxYx30dQnBdl8m0EFBsC40D7yKQpwZFuG1ctjFmtg4ysQFvITuQsIfJW_X5AukON3o:1tWX1E:oiR3pFlhnSRRzaW9KCrnpnfFIBuQfpJw8Dt66XK8fLQ','2025-01-25 08:38:56.906583');
INSERT INTO "django_session" VALUES ('9naq2euhnhk26jod8v8r8jiiltuzwbc5','.eJxVjDsOwjAQBe_iGllefzYxJT1nsNbZNQ6gRIqTCnF3iJQC2jcz76USbWtNW5MljazOyhp1-h0zDQ-ZdsJ3mm6zHuZpXcasd0UftOnrzPK8HO7fQaVWvzVYSyg-QA82U3QuF-md88Z7U4AEMLDBGKKEWJwPZkDmwAimww4A1fsD2yc2qQ:1tWX7Y:pg4ldvgtI9i1Gh3XNMSKTXn8N89a30UAIPPg6GtT5pY','2025-01-25 08:45:28.355309');
INSERT INTO "django_session" VALUES ('sb6krijyph84ia0pt475t8jpvnk67osz','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tXJJL:JvpfjCsp4gKhzMQd_hLO9qE1T-9IRar-nQtqDxqOTTU','2025-01-27 12:12:51.360046');
INSERT INTO "django_session" VALUES ('0abb3pr9scvfdr3ye4imsg898tdkjhwi','.eJxVjEEOwiAQRe_C2pCWYXBw6b5nIDNApGogKe3KeHdt0oVu_3vvv1TgbS1h63kJc1IXZYw6_Y7C8ZHrTtKd663p2Oq6zKJ3RR-066ml_Lwe7t9B4V6-NYoHFifCnAbyEJ1lijha8KNFtAYzAwgkRuIog_XekHEWAUiEzur9AQSfN24:1tXcdb:7OL4M912bGC-Iq4wLVMwmHE3AD99qMKLthEOc9kNCjg','2025-01-28 08:51:03.660964');
INSERT INTO "django_session" VALUES ('oahte5vtzzx8t8bmjoc3jxi32pikoabc','.eJxVjMEOwiAQRP-FsyEUqF08evcbyO6ySNXQpLQn47_bJj1oMqd5b-atIq5LiWuTOY5JXZR16vRbEvJT6k7SA-t90jzVZR5J74o-aNO3Kcnrerh_BwVb2dZsTKDOg3EsgCxCAKEbjDhvs3XSDz0iBLF2iz87Mpx8zoDBZcoB1OcLBRw4Pg:1tXdDg:jB3VGX7BLe6rkk0sEfnvGngqng8k09GlpfQswGDqq4w','2025-01-28 09:28:20.129586');
INSERT INTO "django_session" VALUES ('xlb3u1q7rhy0ymfkmxa0hps4yveh6f2b','.eJxVjDsOwyAQRO9CHSHW5psyvc-AFhaCkwgkY1dR7h5bcpFUI817M2_mcVuL33pa_EzsygbJLr9lwPhM9SD0wHpvPLa6LnPgh8JP2vnUKL1up_t3ULCXfa0cJBHMoACTcuQsZkJhtHU0aq2zkgkVRG1GC3lPGANpAeREFpLIsM8X-po3sQ:1tXdcD:dZ047LWkxTVSJhZRiUBCYrmnCFWA4Fmyjuy0iiwTNZI','2025-01-28 09:53:41.382942');
INSERT INTO "django_session" VALUES ('f6l8yvudk3q0tlxkx2lfmgnrjwzv0bmd','.eJxVjDsOwjAQBe_iGlnOrj8JJT1nsHa9Ng6gRIqTCnF3iJQC2jcz76UibWuNW8tLHEWdFTh1-h2Z0iNPO5E7TbdZp3lal5H1ruiDNn2dJT8vh_t3UKnVb03JObCdEcihMPau92iFAxqHDBCGzibmAr4YYgsoQykE4hlpIJ9RvT_6jjgl:1tXe6u:DWjhmEeRxtrTfeSNsRuDgWkBEc7HZ6D0ln9d5y6YZSg','2025-01-28 10:25:24.658844');
INSERT INTO "django_session" VALUES ('31r8vs06ivhr6k38q7iq23p02b1kk4cb','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tXeBf:OoaRJWZOHlVfGMOcUMRM-MDUUmLMg10zrg4mMcR5M-k','2025-01-28 10:30:19.484714');
INSERT INTO "django_session" VALUES ('7nveaxepqntokis3w11pomf97w4uhzs9','.eJxVjDsOwjAQBe_iGll4_Vso6TlDtM6ucQDZUpxUiLtDpBTQvpl5LzXQupRh7TIPE6uzgqAOv2Oi8SF1I3ynemt6bHWZp6Q3Re-062tjeV529--gUC_fOhwzO0yIJqIDiZJMtBYoO5u8y94BgmH2LJ4hMJ7QejKI2XjGjFa9P_EWN2c:1tY1Ir:77jRZQSjX5lhQGWSGWMBrcxbTLv_rIachvnlY-thwk0','2025-01-29 11:11:17.747196');
INSERT INTO "django_session" VALUES ('iske8p2talrw89u1408knlx22mfi9ytd','.eJxVjMsOwiAQRf-FtSEUZii4dO83NDM8pGogKe3K-O_apAvd3nPOfYmJtrVMW0_LNEdxFnoUp9-RKTxS3Um8U701GVpdl5nlrsiDdnltMT0vh_t3UKiXb405skrOWUKDJmcmDw4NIAxKj1GN1gU2CtmGrC0wJGUweA8RMCAN4v0B_AQ3ew:1tXfmV:qZKyf0nBxa1vJJx1ROayLdpu8nD52hUv_d_VOF_Lfok','2025-01-28 12:12:27.553609');
INSERT INTO "django_session" VALUES ('9deqa8tqgefxw5so3xicljgn0o9syixh','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tXg8P:n0i_dFdB_pV__QEufgrBYkGyK5RgBvj5Ky4nkP4CtPo','2025-01-28 12:35:05.606651');
INSERT INTO "django_session" VALUES ('o2xwomdurber1fp24kfhmmpsythpayvy','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tXgZk:G7M5mSv8WQyVuAYNIaGjXJSxj7uJir0hyx90_FZXxTs','2025-01-28 13:03:20.568232');
INSERT INTO "django_session" VALUES ('hqt03k1wsmjsa37n9uoisj4wg2j3y5ck','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tXgmD:HtZzk3c7XdyzfZkuXLC4GUBMqE2ja8gWqxBRCmAj2hA','2025-01-28 13:16:13.833325');
INSERT INTO "django_session" VALUES ('0teh42n5eobbrri0vtw8x8jmpg9kekn0','.eJxVjMsOwiAQRf-FtSEgAwMu3fcbyPBQqgaS0q6M_y5NutDtOefeN_O0rcVvPS9-TuzCpGGnXxgoPnPdTXpQvTceW12XOfA94YftfGopv65H-3dQqJexVkI67QQJCxANWaBoUWiHxmE6a7Qxg3AJLYIDFIPjLVnQMEhQSrLPF8KlNf8:1tXhZN:HCkANY2W0H9OHE6yj6tX_oCWv09BwlVoN7kK7JSJBJY','2025-01-28 14:07:01.164853');
INSERT INTO "django_session" VALUES ('qje361o3txbi3j0fky93s431cywb4jic','.eJxVjDsOwjAQBe_iGll4s07WlPScwdr1BweQLeVTIe5OIqWAdmbeeyvP61L8OqfJj1FdFJA6_ULh8Ex1N_HB9d50aHWZRtF7og8761uL6XU92r-DwnPZ1miEkJls7wYYyPXnIB11GQUjuIyOBjE2O84bC13EAGStyEYSABj1-QLyjjfC:1tXuSe:2ASctY6t5hvoFNKvouRZQg9DmcrGnkNRa2-LDU1bT-M','2025-01-29 03:52:56.017380');
INSERT INTO "django_session" VALUES ('9y56y8zqbkqlk705bqxvr3scfpbf2l3u','.eJxVjMEOwiAQRP-FsyEsUAoevfcbyO5CpWpoUtqT8d9tkx50jvPezFtE3NYSt5aXOCVxFTqIy29JyM9cD5IeWO-z5Lmuy0TyUORJmxzmlF-30_07KNjKvjbKMNkQuEtZWUo6GMemV45JMyCAsQoCY0feOSRHvSe7Z4QMfkQQny_9kjfB:1tXwOV:XfNA_Cr47JXRWdT1yIcnyc2lxIxHSp3QWqnTOMWSI_k','2025-01-29 05:56:47.735849');
INSERT INTO "django_session" VALUES ('kcnfy2xasbuspplp4sc67qdx0rt8wxvf','.eJxVjMsOwiAUBf-FtSGFlkt16b7fQO4DpGogKe3K-O_apAvdnpk5LxVwW3PYWlzCLOqijFen35GQH7HsRO5YblVzLesyk94VfdCmpyrxeT3cv4OMLX9rBmYBGR0xMVLnEnhPHg3Q4A35aMwQAXuS1AN2rrfAZ6bRWrEp2qTeHzq6ORg:1tXwXS:30XLZx_Q5T0IhNI1NFMJE4Edq8ozpw3PgSMKQ2SQLAg','2025-01-29 06:06:02.722819');
INSERT INTO "django_session" VALUES ('z21ds1r9fj9qenofim6pka071lvju40w','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tXxK8:ZU7gLzFI9j6AlWu3Qcuz23nFbtAZMfFZr1SBTLUs5Bs','2025-01-29 06:56:20.768995');
INSERT INTO "django_session" VALUES ('xwwv44kfngt470ax5hzbf0n81s70kddt','.eJxVjMsOwiAUBf-FtSGFlkt16b7fQO4DpGogKe3K-O_apAvdnpk5LxVwW3PYWlzCLOqijFen35GQH7HsRO5YblVzLesyk94VfdCmpyrxeT3cv4OMLX9rBmYBGR0xMVLnEnhPHg3Q4A35aMwQAXuS1AN2rrfAZ6bRWrEp2qTeHzq6ORg:1tXxgq:jKg07jtMyIWS3prSRpmua6CrPy0NIcbRXgDPd50JkwE','2025-01-29 07:19:48.626770');
INSERT INTO "django_session" VALUES ('2170o9vvxsssjmcyqdql7qstucejzihp','.eJxVjDkOwjAQAP_iGller09K-rzBWh_BAeRIcVIh_o4spYB2ZjRvFujYazh62cKS2ZWhYJdfGCk9SxsmP6jdV57Wtm9L5CPhp-18WnN53c72b1Cp1_HVCGjE7AsaFyWAkmjnlBRJksVQJO-i8ADeZhJFJW2clxZAo3ReR_b5At9nNtw:1tXxw6:qo9Bs-eeev2zUEbz7rvU7XD5zadfs-R1jt1h9JdCu10','2025-01-29 07:35:34.990792');
INSERT INTO "django_session" VALUES ('6dspkxt9ilso6w7yz5wdaeik1y1wyxv3','.eJxVjLsOwjAUQ_8lM4qaNK8ysvcbIif3hhRQK_UxIf6dVuoAiyX72H6LiG2tcVt4jgOJq2iVuPyGCfnJ40HogfE-yTyN6zwkeVTkSRfZT8Sv29n9O6hY6r5mo30o1KJohM5q0znFTSbnOSRLcLCNKQxjgUbpzDYYvyuSgt2t-HwBFLA4ug:1tXyGb:BwWhaeuFUGA6BAN9DSOnA6wo047O4N6BEOv5oKmP-UQ','2025-01-29 07:56:45.559067');
INSERT INTO "django_session" VALUES ('z2iyxuy1860pechgjrsukcvul7bv2212','.eJxVjEEOwiAQRe_C2hCYAVpcuvcMBJhBqoYmpV0Z765NutDtf-_9lwhxW2vYOi9hInEWWpx-txTzg9sO6B7bbZZ5busyJbkr8qBdXmfi5-Vw_w5q7PVbF2c4q6ytKnoYRoeEHrVyVpdsPRgwVCAVHjMaIgus0YDFktgDIyXx_gDLPTee:1tY0Jd:Q6Yz4b_j-rMW2MeBinQfEdleLxHgAQ7xrG3gMrPstB8','2025-01-29 10:08:01.609946');
INSERT INTO "users_location" VALUES (1,'Nairobi');
INSERT INTO "users_location" VALUES (2,'Mombasa');
INSERT INTO "users_location" VALUES (3,'Kisii');
INSERT INTO "users_location" VALUES (4,'Meru');
INSERT INTO "users_location" VALUES (5,'Kisumu');
INSERT INTO "users_location" VALUES (6,'Naivasha');
INSERT INTO "users_location" VALUES (7,'Thika');
INSERT INTO "users_location" VALUES (8,'Kakamega');
INSERT INTO "users_profile" VALUES (1,1,NULL,NULL,NULL);
INSERT INTO "users_profile" VALUES (9,9,3751504423,7454998381,1);
INSERT INTO "users_profile" VALUES (13,13,NULL,NULL,NULL);
INSERT INTO "users_profile" VALUES (14,14,NULL,NULL,NULL);
INSERT INTO "users_profile" VALUES (15,15,NULL,NULL,NULL);
INSERT INTO "users_profile" VALUES (16,16,NULL,NULL,NULL);
INSERT INTO "users_profile" VALUES (17,17,NULL,NULL,NULL);
INSERT INTO "users_profile" VALUES (18,18,30782400,700051264,1);
INSERT INTO "users_profile" VALUES (19,19,2484719,725998363,1);
INSERT INTO "users_profile" VALUES (20,20,25453569,723562999,1);
INSERT INTO "users_profile" VALUES (21,21,20971264,729524524,1);
INSERT INTO "users_profile" VALUES (22,22,22484305,723438644,1);
INSERT INTO "users_profile" VALUES (23,23,31426253,790733243,1);
INSERT INTO "users_profile" VALUES (24,24,23861198,720272040,1);
INSERT INTO "users_profile" VALUES (25,25,22209700,725161482,7);
INSERT INTO "users_profile" VALUES (26,26,33352445,700485252,1);
INSERT INTO "users_profile" VALUES (27,27,25048691,708019806,1);
INSERT INTO "users_profile" VALUES (28,28,24280617,711679785,1);
INSERT INTO "users_profile" VALUES (29,29,24520599,720104332,1);
INSERT INTO "users_profile" VALUES (30,30,32946074,708591764,1);
INSERT INTO "users_profile" VALUES (31,31,34283539,705815413,1);
INSERT INTO "users_profile" VALUES (32,32,46746267,715463357,1);
INSERT INTO "vehicles_bidding" VALUES (126,900000,'2025-01-15 03:54:12.544277',16,28);
INSERT INTO "vehicles_bidding" VALUES (128,300000,'2025-01-15 11:14:22.288488',21,26);
INSERT INTO "vehicles_financier" VALUES (1,'Mycredit Limited');
INSERT INTO "vehicles_financier" VALUES (2,'Test Financier');
INSERT INTO "vehicles_financier" VALUES (3,'Porche');
INSERT INTO "vehicles_fueltype" VALUES (1,'Petrol');
INSERT INTO "vehicles_fueltype" VALUES (2,'Diesel');
INSERT INTO "vehicles_manufactureyear" VALUES (1,2013);
INSERT INTO "vehicles_manufactureyear" VALUES (2,2006);
INSERT INTO "vehicles_manufactureyear" VALUES (3,2022);
INSERT INTO "vehicles_manufactureyear" VALUES (4,2002);
INSERT INTO "vehicles_manufactureyear" VALUES (5,2018);
INSERT INTO "vehicles_manufactureyear" VALUES (6,2006);
INSERT INTO "vehicles_manufactureyear" VALUES (7,2016);
INSERT INTO "vehicles_manufactureyear" VALUES (8,2010);
INSERT INTO "vehicles_manufactureyear" VALUES (9,2003);
INSERT INTO "vehicles_manufactureyear" VALUES (10,2014);
INSERT INTO "vehicles_notificationrecipient" VALUES (7,'autobid@riverlong.com','Autobid Group Email');
INSERT INTO "vehicles_vehicle" VALUES (13,3554005,'2025-01-10 09:25:47.032509','2025-01-15 05:58:50.562471',4300,1200000,2,1,2,1,19,'images/20250113_123200_PlVNbrL.JPG',6,'KBX 722B','818b5ba508934835a31ce521cba8a1be','available','Manual','','Black',5,1,1,'2025-01-10 09:27:29.380386',1,1,1);
INSERT INTO "vehicles_vehicle" VALUES (14,420006,'2025-01-13 13:51:05.117944','2025-01-15 08:31:57.125856',1990,950000,1,1,5,1,10,'images/20250113_113002.jpg',4,'KCZ 023U','bfc5767a4e0a44a9a650009703fa5aee','available','Automatic','','White',3,1,1,'2025-01-13 13:51:59.466042',1,1,1);
INSERT INTO "vehicles_vehicle" VALUES (15,340365,'2025-01-13 14:21:53.031275','2025-01-14 11:04:51.759636',1790,450000,4,1,6,1,11,'images/20250113_111224.jpg',2,'KBH 851W','5e66becb008b458089055edb1273729f','available','Automatic','','Grey',5,1,1,'2025-01-14 09:31:38.979376',1,1,0);
INSERT INTO "vehicles_vehicle" VALUES (16,147835,'2025-01-13 15:10:00.251301','2025-01-15 08:19:31.385354',2490,1200000,1,1,7,6,12,'images/20250113_102854.jpg',4,'KCT 988K','f910321136fa482884c2564c977cb46f','available','Automatic','','white',5,1,1,'2025-01-14 09:31:38.963753',1,1,0);
INSERT INTO "vehicles_vehicle" VALUES (17,136247,'2025-01-13 16:08:41.073993','2025-01-14 12:10:14.303219',2500,1700000,5,2,8,7,13,'images/20250113_124553.jpg',3,'KCS 939J','17f110b5b3d543bbabe61636394eac04','available','Manual','','Black',3,1,1,'2025-01-14 09:31:38.963753',1,1,0);
INSERT INTO "vehicles_vehicle" VALUES (18,153079,'2025-01-13 16:47:03.168831','2025-01-14 09:31:38.948128',3456,1000000,6,1,2,1,15,'images/20250113_121509.jpg',2,'KBX 842W','23b85fb2fc0f47beb086efcfd2d24ad0','available','Automatic','','Black',5,1,1,'2025-01-14 09:31:38.948128',1,1,0);
INSERT INTO "vehicles_vehicle" VALUES (20,190822,'2025-01-13 17:13:26.090187','2025-01-15 08:08:22.867324',1990,900000,8,1,7,8,17,'images/20250113_140601.jpg',4,'KCN 782T','86b41a81c8ad4b8ab5359734bc5272bc','available','Automatic','','Black',8,1,1,'2025-01-14 09:31:38.916876',1,1,0);
INSERT INTO "vehicles_vehicle" VALUES (21,NULL,'2025-01-15 06:28:01.915044','2025-01-15 11:12:52.326097',1794,400000,9,1,9,1,20,'images/20250114_120239.jpg',5,'KBM 463A','810608f608ee46dd93722aa549e1d831','available','Automatic','','Green',5,1,1,'2025-01-15 07:38:18.159797',1,1,0);
INSERT INTO "vehicles_vehicle" VALUES (22,436159,'2025-01-15 12:19:26.136496','2025-01-15 15:32:28.924076',1495,650000,1,1,1,1,21,'images/KCF_657X_7.jpg',0,'KCF 657X','1a0478d0ccee4d649da10fb33c62e073','available','Automatic','','Blue',5,1,1,'2025-01-15 15:32:28.924076',1,1,0);
INSERT INTO "vehicles_vehicle" VALUES (23,163264,'2025-01-15 15:04:11.359052','2025-01-15 15:35:54.121016',1986,2100000,10,1,7,1,22,'images/default-vehicle.png',0,'KDE 005V','b8612731490443e18f8b3cd7e69caa33','idle','Automatic','','Black',5,1,1,NULL,NULL,0,0);
INSERT INTO "vehicles_vehicle" VALUES (24,0,'2025-01-15 16:14:30.980553','2025-01-16 02:08:58.060212',0,0,1,1,2,1,23,'images/20250115_153828.jpg',0,'KDC 762A','ae1832abb85341f8b2666286d37ec1a3','idle','Automatic','','white',5,1,1,NULL,NULL,0,0);
INSERT INTO "vehicles_vehicle" VALUES (25,0,'2025-01-16 02:16:26.150136','2025-01-16 05:30:41.646003',0,0,1,1,2,1,23,'images/20250106_111433.jpg',0,'KCW 931Y','918b38eb1d6f451aa47abf27a5b3fb33','idle','Automatic','','white',5,1,1,NULL,NULL,0,0);
INSERT INTO "vehicles_vehicle" VALUES (26,0,'2025-01-16 02:26:04.277302','2025-01-16 02:26:04.277302',0,0,1,1,8,5,24,'images/20250104_091615.jpg',0,'KCZ 853F','0e8648aacb104ee7846ab9dd36a08ca4','idle','Automatic','','Black',5,1,1,NULL,NULL,0,0);
INSERT INTO "vehicles_vehicle" VALUES (27,0,'2025-01-16 03:30:03.379819','2025-01-16 03:30:03.379819',0,0,1,1,3,1,23,'images/default-vehicle.png',0,'KBR 056J','8bb838b2d99747b09fc55a436e7a506b','idle','Manual','','white',5,1,1,NULL,NULL,0,0);
INSERT INTO "vehicles_vehicle" VALUES (28,0,'2025-01-16 03:51:24.990519','2025-01-16 03:55:12.403423',0,0,1,1,1,1,1,'images/20250110_154602.jpg',0,'KBC 726O','e22c780dc8d342aa9b33938573f0fa3b','idle','Automatic','','white',5,1,1,NULL,NULL,0,0);
INSERT INTO "vehicles_vehicle" VALUES (29,0,'2025-01-16 04:03:17.902063','2025-01-16 04:19:18.842227',0,0,1,1,7,4,4,'images/default-vehicle.png',0,'KBR 690K','998001ae8703443bb73806f2260331f6','idle','Automatic','','Black',5,1,1,NULL,NULL,0,0);
INSERT INTO "vehicles_vehicle" VALUES (30,0,'2025-01-16 04:30:12.374362','2025-01-16 04:30:12.374362',0,0,1,1,6,1,8,'images/default-vehicle.png',0,'KBH 518U','01995757002e4420a60b13d618ea8989','idle','Automatic','','white',5,1,1,NULL,NULL,0,0);
INSERT INTO "vehicles_vehicle" VALUES (31,0,'2025-01-16 05:49:28.139544','2025-01-16 05:49:28.139544',0,0,1,1,2,1,1,'images/default-vehicle.png',0,'KDE 002C','3130a9fbbf0a48bc8dc2668751028ff0','idle','Automatic','','Black',5,1,NULL,NULL,NULL,0,0);
INSERT INTO "vehicles_vehiclebody" VALUES (1,'Hatchback');
INSERT INTO "vehicles_vehiclebody" VALUES (2,'Station Wagon');
INSERT INTO "vehicles_vehiclebody" VALUES (3,'Coupe');
INSERT INTO "vehicles_vehiclebody" VALUES (5,'Track');
INSERT INTO "vehicles_vehiclebody" VALUES (6,'Sedan');
INSERT INTO "vehicles_vehiclebody" VALUES (7,'suv');
INSERT INTO "vehicles_vehiclebody" VALUES (8,'Cover Body');
INSERT INTO "vehicles_vehiclebody" VALUES (9,'MPV');
INSERT INTO "vehicles_vehicleimage" VALUES (38,13,'vehicleimages/20250109_102224.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (39,13,'vehicleimages/20250109_102157.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (40,13,'vehicleimages/20250109_102034.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (41,13,'vehicleimages/20250109_101947.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (42,13,'vehicleimages/20250109_101846.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (43,13,'vehicleimages/20250109_101908.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (44,13,'vehicleimages/20250109_101833.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (45,16,'vehicleimages/20250113_102840.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (46,18,'vehicleimages/20250113_121509.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (47,18,'vehicleimages/20250113_121527.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (48,18,'vehicleimages/20250113_121544.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (49,18,'vehicleimages/20250113_121652.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (50,20,'vehicleimages/20250113_140444.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (51,20,'vehicleimages/20250113_140512.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (52,20,'vehicleimages/20250113_140139.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (53,20,'vehicleimages/20250113_140233.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (54,20,'vehicleimages/20250113_140355.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (55,14,'vehicleimages/20250113_112115.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (56,14,'vehicleimages/20250113_112108.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (57,14,'vehicleimages/20250113_112037.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (58,15,'vehicleimages/20250113_111155.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (59,15,'vehicleimages/20250113_105843.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (60,15,'vehicleimages/20250113_111935.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (61,15,'vehicleimages/20250113_111553.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (62,15,'vehicleimages/20250113_111638.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (63,17,'vehicleimages/20250113_124543.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (64,17,'vehicleimages/20250113_124512.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (65,17,'vehicleimages/20250113_125239.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (66,17,'vehicleimages/20250113_124421.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (67,17,'vehicleimages/20250113_124459.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (73,21,'vehicleimages/20250114_120308.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (74,21,'vehicleimages/20250114_120711.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (75,21,'vehicleimages/20250114_120425.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (76,21,'vehicleimages/20250114_120408.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (77,21,'vehicleimages/20250114_120358.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (78,21,'vehicleimages/20250114_120352.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (79,21,'vehicleimages/20250114_120239.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (80,21,'vehicleimages/20250114_120223.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (81,16,'vehicleimages/WhatsApp_Image_2025-01-15_at_11.13.17.jpeg');
INSERT INTO "vehicles_vehicleimage" VALUES (82,16,'vehicleimages/WhatsApp_Image_2025-01-15_at_11.13.16.jpeg');
INSERT INTO "vehicles_vehicleimage" VALUES (83,16,'vehicleimages/WhatsApp_Image_2025-01-15_at_11.13.15_3.jpeg');
INSERT INTO "vehicles_vehicleimage" VALUES (84,16,'vehicleimages/WhatsApp_Image_2025-01-15_at_11.13.15_2.jpeg');
INSERT INTO "vehicles_vehicleimage" VALUES (85,16,'vehicleimages/WhatsApp_Image_2025-01-15_at_11.13.15_1.jpeg');
INSERT INTO "vehicles_vehicleimage" VALUES (86,16,'vehicleimages/WhatsApp_Image_2025-01-15_at_11.13.15.jpeg');
INSERT INTO "vehicles_vehicleimage" VALUES (87,16,'vehicleimages/WhatsApp_Image_2025-01-15_at_11.13.13_1.jpeg');
INSERT INTO "vehicles_vehicleimage" VALUES (88,16,'vehicleimages/WhatsApp_Image_2025-01-15_at_11.13.13.jpeg');
INSERT INTO "vehicles_vehicleimage" VALUES (89,22,'vehicleimages/KCF_657X_2.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (90,22,'vehicleimages/KCF_657X_4.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (91,22,'vehicleimages/KCF_657X_5.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (92,22,'vehicleimages/KCF_657X_6.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (93,22,'vehicleimages/KCF_657X_7.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (94,22,'vehicleimages/KCF_657X_1.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (95,22,'vehicleimages/KCF_657X_8.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (96,22,'vehicleimages/KCF_657X_9.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (97,22,'vehicleimages/KCF_657X_10.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (98,24,'vehicleimages/20241206_090855.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (99,25,'vehicleimages/20250106_111446.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (100,25,'vehicleimages/20250106_111433.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (101,25,'vehicleimages/20250106_111507.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (102,25,'vehicleimages/20250106_111521.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (103,26,'vehicleimages/20250104_091642.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (104,28,'vehicleimages/20250110_154551.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (105,28,'vehicleimages/20250110_154630.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (106,28,'vehicleimages/20250110_154611.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (107,28,'vehicleimages/20250110_154648.jpg');
INSERT INTO "vehicles_vehicleimage" VALUES (108,29,'vehicleimages/20250109_155327.jpg');
INSERT INTO "vehicles_vehiclemake" VALUES (1,'Toyota');
INSERT INTO "vehicles_vehiclemake" VALUES (2,'Porche');
INSERT INTO "vehicles_vehiclemake" VALUES (3,'Range Rover');
INSERT INTO "vehicles_vehiclemake" VALUES (4,'Mercedes');
INSERT INTO "vehicles_vehiclemake" VALUES (5,'Nissan');
INSERT INTO "vehicles_vehiclemake" VALUES (6,'Subaru');
INSERT INTO "vehicles_vehiclemake" VALUES (7,'ISUZU');
INSERT INTO "vehicles_vehiclemake" VALUES (8,'Mitsubishi');
INSERT INTO "vehicles_vehiclemodel" VALUES (1,'Land cruiser V8');
INSERT INTO "vehicles_vehiclemodel" VALUES (2,'Cayenne');
INSERT INTO "vehicles_vehiclemodel" VALUES (3,'Evoque');
INSERT INTO "vehicles_vehiclemodel" VALUES (4,'C200');
INSERT INTO "vehicles_vehiclemodel" VALUES (5,'vanguard');
INSERT INTO "vehicles_vehiclemodel" VALUES (6,'Note');
INSERT INTO "vehicles_vehiclemodel" VALUES (7,'Carrera');
INSERT INTO "vehicles_vehiclemodel" VALUES (8,'Axio');
INSERT INTO "vehicles_vehiclemodel" VALUES (9,'Prius');
INSERT INTO "vehicles_vehiclemodel" VALUES (10,'Dyna');
INSERT INTO "vehicles_vehiclemodel" VALUES (11,'Allion ZZT240');
INSERT INTO "vehicles_vehiclemodel" VALUES (12,'Outback BRM');
INSERT INTO "vehicles_vehiclemodel" VALUES (13,'D-MAX TFR86');
INSERT INTO "vehicles_vehiclemodel" VALUES (14,'Land Cruiser Prado GRG120W');
INSERT INTO "vehicles_vehiclemodel" VALUES (15,'Harrier GSU30W');
INSERT INTO "vehicles_vehiclemodel" VALUES (16,'Outback BS9');
INSERT INTO "vehicles_vehiclemodel" VALUES (17,'Outlander CW4W');
INSERT INTO "vehicles_vehiclemodel" VALUES (18,'Prado J120');
INSERT INTO "vehicles_vehiclemodel" VALUES (19,'Land Cruiser Prado GRG120W');
INSERT INTO "vehicles_vehiclemodel" VALUES (20,'Wish ZNE14G');
INSERT INTO "vehicles_vehiclemodel" VALUES (21,'Rush');
INSERT INTO "vehicles_vehiclemodel" VALUES (22,'Harrier ZSU60W');
INSERT INTO "vehicles_vehiclemodel" VALUES (23,'Probox');
INSERT INTO "vehicles_vehiclemodel" VALUES (24,'X-Trail');
INSERT INTO "vehicles_vehicleview" VALUES (58,'2025-01-10 09:28:37.002917',16,13);
INSERT INTO "vehicles_vehicleview" VALUES (59,'2025-01-10 10:08:03.537733',1,13);
INSERT INTO "vehicles_vehicleview" VALUES (63,'2025-01-10 14:33:30.197585',14,13);
INSERT INTO "vehicles_vehicleview" VALUES (64,'2025-01-11 06:42:02.267896',17,13);
INSERT INTO "vehicles_vehicleview" VALUES (70,'2025-01-11 09:03:21.735428',18,13);
INSERT INTO "vehicles_vehicleview" VALUES (72,'2025-01-13 13:52:33.718878',1,14);
INSERT INTO "vehicles_vehicleview" VALUES (73,'2025-01-13 17:15:31.154628',1,15);
INSERT INTO "vehicles_vehicleview" VALUES (74,'2025-01-13 17:15:37.056851',1,16);
INSERT INTO "vehicles_vehicleview" VALUES (75,'2025-01-13 17:15:46.716914',1,20);
INSERT INTO "vehicles_vehicleview" VALUES (76,'2025-01-13 17:16:00.498549',1,17);
INSERT INTO "vehicles_vehicleview" VALUES (77,'2025-01-13 17:16:15.145342',1,18);
INSERT INTO "vehicles_vehicleview" VALUES (78,'2025-01-14 04:49:05.913734',17,18);
INSERT INTO "vehicles_vehicleview" VALUES (79,'2025-01-14 04:50:17.724662',17,16);
INSERT INTO "vehicles_vehicleview" VALUES (80,'2025-01-14 05:03:15.840918',16,14);
INSERT INTO "vehicles_vehicleview" VALUES (83,'2025-01-14 06:37:53.049166',17,14);
INSERT INTO "vehicles_vehicleview" VALUES (84,'2025-01-14 07:19:20.285961',18,20);
INSERT INTO "vehicles_vehicleview" VALUES (86,'2025-01-14 07:57:19.887462',17,17);
INSERT INTO "vehicles_vehicleview" VALUES (87,'2025-01-14 09:55:35.595756',16,17);
INSERT INTO "vehicles_vehicleview" VALUES (88,'2025-01-14 11:04:51.790885',26,15);
INSERT INTO "vehicles_vehicleview" VALUES (89,'2025-01-14 12:46:30.939967',16,16);
INSERT INTO "vehicles_vehicleview" VALUES (90,'2025-01-15 03:53:41.379075',28,16);
INSERT INTO "vehicles_vehicleview" VALUES (93,'2025-01-15 05:58:50.593720',29,13);
INSERT INTO "vehicles_vehicleview" VALUES (94,'2025-01-15 07:43:40.660085',1,21);
INSERT INTO "vehicles_vehicleview" VALUES (95,'2025-01-15 07:58:02.579461',31,21);
INSERT INTO "vehicles_vehicleview" VALUES (96,'2025-01-15 07:58:22.394976',30,21);
INSERT INTO "vehicles_vehicleview" VALUES (97,'2025-01-15 08:08:07.381385',31,20);
INSERT INTO "vehicles_vehicleview" VALUES (98,'2025-01-15 08:08:22.882957',30,20);
INSERT INTO "vehicles_vehicleview" VALUES (99,'2025-01-15 08:31:57.157062',31,14);
INSERT INTO "vehicles_vehicleview" VALUES (100,'2025-01-15 08:49:18.772940',17,21);
INSERT INTO "vehicles_vehicleview" VALUES (101,'2025-01-15 11:12:52.404221',26,21);
INSERT INTO "vehicles_yard" VALUES (1,'Riverlong Storage Yard','https://maps.app.goo.gl/x6HtcuMXTBdtt3Gj8');
INSERT INTO "vehicles_yard" VALUES (2,'StarTruck Yard','https://maps.app.goo.gl/sHHKRzVmYoqtpBKcA');
CREATE INDEX IF NOT EXISTS "auth_group_permissions_group_id_b120cbf9" ON "auth_group_permissions" (
	"group_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_group_permissions_group_id_permission_id_0cd325b0_uniq" ON "auth_group_permissions" (
	"group_id",
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "auth_group_permissions_permission_id_84c5c92e" ON "auth_group_permissions" (
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "auth_permission_content_type_id_2f476e4b" ON "auth_permission" (
	"content_type_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_permission_content_type_id_codename_01ab375a_uniq" ON "auth_permission" (
	"content_type_id",
	"codename"
);
CREATE INDEX IF NOT EXISTS "auth_user_groups_group_id_97559544" ON "auth_user_groups" (
	"group_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_groups_user_id_6a12ed8b" ON "auth_user_groups" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_user_groups_user_id_group_id_94350c0c_uniq" ON "auth_user_groups" (
	"user_id",
	"group_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_user_permissions_permission_id_1fbb5f2c" ON "auth_user_user_permissions" (
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "auth_user_user_permissions_user_id_a95ead1b" ON "auth_user_user_permissions" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "auth_user_user_permissions_user_id_permission_id_14a6b632_uniq" ON "auth_user_user_permissions" (
	"user_id",
	"permission_id"
);
CREATE INDEX IF NOT EXISTS "django_admin_log_content_type_id_c4bce8eb" ON "django_admin_log" (
	"content_type_id"
);
CREATE INDEX IF NOT EXISTS "django_admin_log_user_id_c564eba6" ON "django_admin_log" (
	"user_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "django_content_type_app_label_model_76bd3d3b_uniq" ON "django_content_type" (
	"app_label",
	"model"
);
CREATE INDEX IF NOT EXISTS "django_session_expire_date_a5c62663" ON "django_session" (
	"expire_date"
);
CREATE INDEX IF NOT EXISTS "users_profile_location_id_b4d62440" ON "users_profile" (
	"location_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_auction_approved_by_id_4699534f" ON "vehicles_auction" (
	"approved_by_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_auction_vehicles_auction_id_56225749" ON "vehicles_auction_vehicles" (
	"auction_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "vehicles_auction_vehicles_auction_id_vehicle_id_34c55eee_uniq" ON "vehicles_auction_vehicles" (
	"auction_id",
	"vehicle_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_auction_vehicles_vehicle_id_265f41a4" ON "vehicles_auction_vehicles" (
	"vehicle_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_auctionhistory_auction_id_f1a29f06" ON "vehicles_auctionhistory" (
	"auction_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_auctionhistory_vehicle_id_224cc7cc" ON "vehicles_auctionhistory" (
	"vehicle_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_bid_user_id_7b183c56" ON "vehicles_bidding" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_bid_vehicle_id_4c930998" ON "vehicles_bidding" (
	"vehicle_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_vehicle_Financier_id_768e0f97" ON "vehicles_vehicle" (
	"Financier_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_vehicle_YOM_id_0e0fa63a" ON "vehicles_vehicle" (
	"YOM_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_vehicle_approved_by_id_3ec9b4a9" ON "vehicles_vehicle" (
	"approved_by_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_vehicle_body_type_id_b0b113e6" ON "vehicles_vehicle" (
	"body_type_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_vehicle_fuel_type_id_11309cd5" ON "vehicles_vehicle" (
	"fuel_type_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_vehicle_make_id_08aa3cd8" ON "vehicles_vehicle" (
	"make_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_vehicle_model_id_0d0e87d6" ON "vehicles_vehicle" (
	"model_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_vehicle_yard_id_0a7d1a51" ON "vehicles_vehicle" (
	"yard_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_vehicleimage_vehicle_id_7eda5167" ON "vehicles_vehicleimage" (
	"vehicle_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_vehicleview_user_id_56f734f8" ON "vehicles_vehicleview" (
	"user_id"
);
CREATE INDEX IF NOT EXISTS "vehicles_vehicleview_vehicle_id_4afffebd" ON "vehicles_vehicleview" (
	"vehicle_id"
);
CREATE UNIQUE INDEX IF NOT EXISTS "vehicles_vehicleview_vehicle_id_user_id_10ed4d76_uniq" ON "vehicles_vehicleview" (
	"vehicle_id",
	"user_id"
);
COMMIT;
