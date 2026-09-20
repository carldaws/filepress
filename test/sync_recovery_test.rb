require "test_helper"
require_relative "dummy/db/migrate/20250422195517_create_posts"

class SyncRecoveryTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "sync skips quietly before the table exists and recovers once it appears" do
    Post.connection_pool.with_connection { |connection| connection.drop_table(:posts) }

    assert_nothing_raised { Filepress.sync }

    CreatePosts.new.migrate(:up)
    Filepress.sync

    assert Post.table_exists?
    assert_equal 2, Post.count
  end
end
