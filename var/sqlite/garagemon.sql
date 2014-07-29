## /var/sqllite and garagemon.db are permissions 777, need to fix

# http://www.raspberrypiblog.com/2012/11/getting-started-with-databases-on-pi.html

# root@raspberrypi:/var# sqlite3 garagemon.db
# SQLite version 3.7.13 2012-06-11 02:05:22
# Enter ".help" for instructions
# Enter SQL statements terminated with a ";"
CREATE TABLE position (door_name TEXT, current_position TEXT, locked NUMERIC, time NUMERIC, reminder_sent NUMERIC);
INSERT INTO position values ("Door 1", 0, 0, 0, 0);
CREATE TABLE message_type (id NUMERIC, type_name TEXT);
INSERT INTO message_type values (0, "open");
INSERT INTO message_type values (1, "still open");
INSERT INTO message_type values (3, "closed");
CREATE TABLE yesno (id NUMERIC, name TEXT);
INSERT INTO yesno values (0, "yes");
INSERT INTO yesno values (1, "no");
CREATE TABLE notify_log (id INTEGER PRIMARY KEY AUTOINCREMENT, type_name NUMERIC, ssl_id TEXT, time NUMERIC, ack NUMERIC);
CREATE TABLE device_registration (id INTEGER PRIMARY KEY AUTOINCREMENT, device_id TEXT, time NUMERIC, active NUMERIC);
CREATE TABLE dooraction (id INTEGER PRIMARY KEY AUTOINCREMENT, command TEXT, request_time NUMERIC, completion_time NUMERIC);
