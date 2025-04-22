require "test_helper"

class FilepressTest < ActiveSupport::TestCase
  def setup
    FileUtils.mkdir_p(Rails.root.join("app/content/posts"))
    File.write(Rails.root.join("app/content/posts/example.md"), <<~MD)
      ---
      slug: example-post
      title: Example Title
      ---
      This is the post body.
    MD
  end

  def teardown
    FileUtils.rm_rf(Rails.root.join("app/content/posts"))
    Post.delete_all
  end

  test "sync creates or updates records from markdown" do
    Filepress.sync
    post = Post.find_by(slug: "example-post")

    assert post
    assert_equal "Example Title", post.title
    assert_equal "This is the post body.", post.body
  end

  test "sync removes stale records" do
    Post.create!(slug: "old", title: "Old", body: "Old content")
    Filepress.sync
    refute Post.exists?(slug: "old")
  end
end
