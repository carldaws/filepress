require "filepress/version"
require "filepress/railtie"
require "filepress/model"

module Filepress
  class << self
    def sync
      Rails.application.eager_load!
      models = ActiveRecord::Base.descendants.select { |model| model.respond_to? :filepress_options }

      models.each do |model|
        options = model.filepress_options
        raise "Filepress options missing for #{model.name}" unless options

        path = Rails.root.join(options[:from])
        key = options[:key]
        body_attribute = options[:body]

        keys = Dir.glob("#{path}/#{options[:glob]}").map do |file|
          raw = File.read(file)
          frontmatter, body = raw.split(/^---\s*$/, 3).reject(&:empty?)
          data = YAML.safe_load(frontmatter, symbolize_names: true)
          content = body.strip

          identifier = data[key]
          raise "Missing key `#{key}` in frontmatter for #{file}" unless identifier

          record = model.find_or_initialize_by(key => identifier)
          record.assign_attributes(data)
          record.send("#{body_attribute}=", content)
          record.save!

          identifier
        end

        model.where.not(key => keys).destroy_all if options[:destroy_stale]
      end
    end
  end
end
