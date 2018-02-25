require 'sqlite3'

$db = SQLite3::Database.new 'database.db'

$db.execute <<-SQL
  create table if not exists users (
    username varchar(64) PRIMARY KEY,
    password_hash varchar(128),
    is_enabled boolean
  );
SQL

$db.execute <<-SQL
  create table if not exists quotes (
    id int PRIMARY KEY,
    quote text,
    author varchar(64)
  );
SQL

