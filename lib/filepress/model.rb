module Filepress
  module Model
    def filepress(from: nil, extensions: ["md"], key: :slug, body: :body, destroy_stale: true)
      class_attribute :filepress_options, instance_accessor: false

      self.filepress_options = {
        from: from || Rails.root.join("app", "content", model_name.plural).to_s,
        extensions: extensions,
        key: key,
        body: body,
        destroy_stale: destroy_stale
      }

      Filepress.register(self, filepress_options)
    end
  end
end
