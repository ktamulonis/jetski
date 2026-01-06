# test/test_helper.rb
ENV["JETSKI_ENV"] = "test"

require "minitest/autorun"
require "fileutils"
require "sqlite3"

# ---- Create test DB FIRST ----

TEST_DB_PATH = File.expand_path("../tmp/test.sqlite3", __dir__)
FileUtils.mkdir_p(File.dirname(TEST_DB_PATH))
FileUtils.rm_f(TEST_DB_PATH)

TEST_DB = SQLite3::Database.new(TEST_DB_PATH)

TEST_DB.execute <<~SQL
  CREATE TABLE chats (
    id INTEGER PRIMARY KEY,
    title TEXT,
    created_at TEXT,
    updated_at TEXT
  );
SQL

TEST_DB.execute <<~SQL
  CREATE TABLE messages (
    id INTEGER PRIMARY KEY,
    chat_id INTEGER,
    content TEXT,
    created_at TEXT,
    updated_at TEXT
  );
SQL

# ---- Load Jetski AFTER DB exists ----
require_relative "../lib/jetski"

# ---- HARD OVERRIDE Jetski DB access (THIS IS THE KEY) ----
module Jetski
  module Database
    module Base
      def db
        TEST_DB
      end
    end
  end
end

# ---- Disable Autoloader in tests ----
module Jetski
  module Autoloader
    def self.call; end
  end
end

# ---- Define models AFTER DB + override ----
class Chat < Jetski::Model; end
class Message < Jetski::Model; end

Chat.define_attribute_methods
Message.define_attribute_methods

Jetski::Family.bootstrap!([Chat, Message])

