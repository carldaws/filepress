# Filepress

Filepress is a minimal Rails plugin that syncs content from flat files to ActiveRecord models. Write your posts in Markdown, version control them with git, and query them with ActiveRecord.

## Build a blog with Filepress

### 1. Install the gem

```ruby
gem "filepress"
```

### 2. Generate a Post model

Include a `slug` field to serve as the unique identifier (derived from the filename) and a `body` field for the content:

```bash
bin/rails generate model Post title:string slug:string:uniq body:text published:boolean
bin/rails db:migrate
```

### 3. Enable Filepress

```ruby
class Post < ApplicationRecord
  filepress
end
```

### 4. Write a post

Create a Markdown file at `app/content/posts/hello-world.md`. The filename becomes the slug, and YAML frontmatter maps to model attributes:

```markdown
---
title: Hello World
published: true
---

This is my first post!
```

Filepress syncs your content to the database automatically — on boot, on deploy, and whenever files change in development.

### 5. Add a controller and routes

```ruby
# config/routes.rb
resources :posts, only: [:index, :show]
```

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find_by!(slug: params[:id])
  end
end
```

Override `to_param` so Rails generates URLs using the slug:

```ruby
class Post < ApplicationRecord
  filepress

  def to_param
    slug
  end
end
```

### 6. Add views

```erb
<%# app/views/posts/index.html.erb %>
<% @posts.each do |post| %>
  <h2><%= link_to post.title, post %></h2>
<% end %>
```

```erb
<%# app/views/posts/show.html.erb %>
<h1><%= @post.title %></h1>
<%= @post.body.html_safe %>
```

### 7. Render Markdown as HTML

Filepress stores the raw file content. To render Markdown to HTML at sync time, add a gem like [Kramdown](https://kramdown.gettalong.org) and a `before_save` callback:

```ruby
gem "kramdown"
gem "kramdown-parser-gfm"
```

```ruby
class Post < ApplicationRecord
  filepress

  before_save :render_body, if: :body_changed?

  def to_param
    slug
  end

  private

  def render_body
    self.body = Kramdown::Document.new(body, input: "GFM").to_html
  end
end
```

The body is converted once on sync, not on every request. Any Markdown library works — Redcarpet, CommonMarker, etc.

## How it works

Filepress reads your content files, extracts YAML frontmatter, and uses the values to populate or update model attributes. The rest of the file becomes the body.

- Syncs are wrapped in a transaction — if any file fails, nothing changes
- Unknown frontmatter keys (that don't match a column) are silently ignored
- In development, Rails' built-in file watcher picks up live edits without a server restart

## Configuration

Customise Filepress by passing options to `filepress`:

### `from:` — Custom content directory

```ruby
filepress from: "app/my_custom_content_folder"
```

### `extensions:` — File types besides Markdown

```ruby
filepress extensions: ["html", "txt"]
```

### `key:` — Unique identifier other than `slug`

```ruby
filepress key: :name
```

### `body:` — Attribute that stores the main content

```ruby
filepress body: :content
```

### `destroy_stale:` — Keep records when files are removed

By default, Filepress deletes records when the corresponding file is removed. Disable this with:

```ruby
filepress destroy_stale: false
```
