require "test_helper"

class FilepressTest < ActiveSupport::TestCase
  def setup
    super
    FileUtils.mkdir_p(Rails.root.join("app/content/posts"))

    File.write(Rails.root.join("app/content/posts/hello-world.md"), <<~MD)
      ---
      title: Hello World
      published: true
      ---
      This is the post body.
    MD

    File.write(Rails.root.join("app/content/posts/draft.md"), <<~MD)
      ---
      title: Draft Post
      published: false
      ---
      Still working on this.
    MD

    Post.filepress
  end

  def teardown
    FileUtils.rm_rf(Rails.root.join("app/content/posts"))
    Post.delete_all
    super
  end

  test "syncs records on register" do
    assert_equal 2, Post.count
  end

  test "sets slug from filename" do
    assert Post.exists?(slug: "hello-world")
    assert Post.exists?(slug: "draft")
  end

  test "sets attributes from frontmatter" do
    post = Post.find_by(slug: "hello-world")

    assert_equal "Hello World", post.title
    assert post.published
  end

  test "sets body from content after frontmatter" do
    post = Post.find_by(slug: "hello-world")

    assert_equal "This is the post body.", post.body
  end

  test "updates existing records on re-sync" do
    post = Post.find_by(slug: "hello-world")

    Filepress.sync

    assert_equal 2, Post.count
    assert_equal "Hello World", post.reload.title
  end

  test "removes stale records" do
    Post.create!(slug: "stale", title: "Stale", body: "Old content")
    assert_equal 3, Post.count

    Filepress.sync

    assert_equal 2, Post.count
    refute Post.exists?(slug: "stale")
  end

  test "respects destroy_stale: false" do
    Filepress.registry.clear
    Post.filepress(destroy_stale: false)
    Post.create!(slug: "keep-me", title: "Keep", body: "Keep this")

    Filepress.sync

    assert Post.exists?(slug: "keep-me")
  end

  test "ignores unknown frontmatter keys" do
    File.write(Rails.root.join("app/content/posts/unknown.md"), <<~MD)
      ---
      title: Test
      nonexistent_column: value
      ---
      Body.
    MD

    Filepress.sync

    post = Post.find_by(slug: "unknown")
    assert_equal "Test", post.title
  end

  test "handles files with no frontmatter" do
    File.write(Rails.root.join("app/content/posts/bare.md"), "Just a body.")

    Filepress.sync

    post = Post.find_by(slug: "bare")
    assert_equal "Just a body.", post.body
  end
end
