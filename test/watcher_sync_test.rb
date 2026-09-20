require "test_helper"

class WatcherSyncTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  CONTENT_DIR = Rails.root.join("app", "content", "posts").to_s

  test "a watcher tick picks up added and removed content files" do
    checker = Rails.application.config.file_watcher.new([], { CONTENT_DIR => ["md"] }) { Filepress.sync }
    new_file = File.join(CONTENT_DIR, "breaking-news.md")

    File.write(new_file, <<~MD)
      ---
      title: Breaking News
      published: true
      ---

      Stop the presses.
    MD

    assert checker.execute_if_updated
    post = Post.find_by(slug: "breaking-news")
    assert_equal "Breaking News", post.title
    assert_equal "Stop the presses.", post.body.strip
  ensure
    File.delete(new_file) if File.exist?(new_file)
    Filepress.sync
    assert_nil Post.find_by(slug: "breaking-news")
  end
end
