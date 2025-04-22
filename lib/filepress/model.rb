module Filepress
  module Model
    def filepress(from: nil, glob: "*.md", key: :slug, body: :body, destroy_stale: true)
      class_attribute :filepress_options, instance_accessor: false, default: {}

      self.filepress_options = {
        from: from || "app/content/#{name.underscore.pluralize}",
        glob: glob,
        key: key,
        body: body,
        destroy_stale: destroy_stale
      }
    end
  end
end
