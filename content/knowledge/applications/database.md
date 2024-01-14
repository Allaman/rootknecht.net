---
title: Database
summary: Some notes related to interact with MySQL databases
---

## Create new MySQL database and user

```sql
mysql -u root -p
create database name;
grant all privileges on database.* to 'user'@'localhost' identified by "password";
flush privileges;
```

## Get MySQL char set

```sql
SELECT default_character_set_name FROM information_schema.SCHEMATA S WHERE schema_name = "DBNAME";
SELECT CCSA.character_set_name FROM information_schema.`TABLES` T,information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` CCSA WHERE CCSA.collation_name = T.table_collation AND T.table_schema = "DBNAME" AND T.table_name = "TABLENAME";
```

## Set MySQL char set to utf-8

Whole database

```sql
ALTER DATABASE "DBNAME" CHARACTER SET utf8 COLLATE utf8_general_ci;
```

All tables in a database
cat .my.cnf

```ini
[client]
user=USERNAME
password="PASSWORD"
```

```sh
mysql --database=DBNAME -B -N -e "SHOW TABLES" | awk '{print "SET foreign_key_checks = 0; ALTER TABLE", $1, "CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci; SET foreign_key_checks = 1; "}' | mysql --database=DBNAME
```

## Full dump of a database

```
mysqldump <DB_NAME> --result-file=DB_DUMP.sql --host=<DB_HOST> --user=admin --port=3306 --password
```

## Export all mysql tables to csv files

```bash
mysqldump ovs -u root -p -T /path/to/folder --fields-terminated-by=,
```

The target folder must be writeable from the mysql process user

## Check mysql/mariadb user and auth

```sql
SELECT user,authentication_string,plugin,host FROM mysql.user;
```

## Create mysql backup user (read-only)

```sql
GRANT SELECT,LOCK TABLES ON DBNAME.* TO 'backup'@'localhost';
```
