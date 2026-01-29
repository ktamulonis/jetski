require "bundler/setup"
require "fileutils"
require "tmpdir"
require "minitest/autorun"

test_db = ":memory:"
ENV["JETSKI_DB_PATH"] = test_db
unless test_db == ":memory:"
  FileUtils.mkdir_p(File.dirname(test_db))
  FileUtils.rm_f(test_db)
end

require "jetski"
require_relative "support/fakes"

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
