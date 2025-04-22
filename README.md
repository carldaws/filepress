# Filepress

Filepress is a minimal Rails plugin that offers the best of both worlds for content management:
- Write and version control your content in Markdown (or a similar format)
- Sync it seamlessly to ActiveRecord models so you can harness the full power of a Rails backend.

Ideal for blogs, documentation, or any content-driven Rails app where you want the flexibility of flat files and the structure of a database.

## Getting Started

1. Install the gem

Add it to your Gemfile:

```ruby
gem "filepress"
```
Then run:

```bash
bundle install
```

2. Create a model to represent your content

Be sure to include a field that can serve as a unique identifier (e.g. `slug`):

```bash
rails g model Post title:string slug:string body:text
```

3. Enable Filepress for your model

Use the `filepress` method in your model class:

```ruby
class Post < ApplicationRecord
    filepress
end
```

4. Add some content

Create Markdown files in `app/content/posts`. Each file should include frontmatter:

```markdown
---
title: My First Post
slug: first
---

# Hello, this is my first post
```

5. Sync your content

Run the sync task to import your files into the database:

```bash
bin/rails filepress:sync
```

That’s it! You’re now free to query your content via ActiveRecord like any other model. Filepress doesn't dictate how you render the body—use a Markdown parser like Kramdown, Redcarpet, or similar.

## How it works

Filepress reads your content files, extracts YAML frontmatter, and uses the values to populate or update model attributes. The rest of the file becomes the value of the body attribute (or another field, if configured).

## Configuration

You can customize how Filepress behaves by passing options to `filepress`:

### `from:` - Set a custom content directory

```ruby
class Post
    filepress from: "app/my_custom_content_folder"
end
```

### `glob:` - Use filetypes besides Markdown

```ruby
class Post
    filepress glob: "*.html"
end
```

### `key:` - Use a unique identifier other than `slug`

```ruby
class Post
    filepress key: :name
end
```

### `body:` - Set which attribute stores the main content

```ruby
class Post
    filepress body: :content
end
```

### `destroy_stale:` - Prevent deletion of records when files are removed

By default, Filepress deletes records when the corresponding file is removed. Disable this behavior with:

```ruby
class Post
    filepress destroy_stale: false
end
```

## Why Filepress?

Filepress is for you if:

- You prefer writing content in files
- You want the convenience of version control for content
- And you still want powerful querying, associations, validations and all the other Rails goodness

