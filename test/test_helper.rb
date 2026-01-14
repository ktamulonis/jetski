require "bundler/setup"
require "minitest/autorun"
require "jetski"

# Load Jetski internals (same as console)
Jetski::Autoloader.call

# ---- TEST MODEL ----
class TestMessage < Jetski::Model
end

# ---- TEST TABLE ----
Jetski::Database::Base.db.execute <<~SQL
  CREATE TABLE IF NOT EXISTS testmessages (
    id INTEGER PRIMARY KEY,
    chat_id INTEGER,
    content TEXT,
    role TEXT,
    created_at TEXT
  );
SQL

# ---- LOAD ALL TEST FILES ----
Dir[File.join(__dir__, "*_test.rb")].each do |file|
  require file unless file.end_with?("test_helper.rb")
end

