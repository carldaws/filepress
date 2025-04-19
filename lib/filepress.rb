# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"
require "active_support/concern"

require_relative "filepress/version"

module Filepress
  class Syncer
    def self.sync!(model_class)
      opts = model_class.filepress_options
      raise "Missing Filepress Options" unless opts

      path = Rails.root.join(opts[:path])
      key = opts[:key]
      content_attr = opts[:content_attribute]

      seen_keys = []

      Dir.glob("#{path}/#{opts[:glob]}").each do |file|
        raw = File.read(file)
        frontmatter, body = raw.split(/^---\s*$/, 3).reject(&:empty?)
        data = YAML.safe_load(frontmatter, symbolize_names: true)
        content = body.strip

        identifier = data[key]
        raise "Missing key `#{key}` in frontmatter for #{file}" unless identifier

        seen_keys << identifier

        record = model_class.find_or_initialize_by(key => identifier)
        record.assign_attributes(data)
        record.send("#{content_attr}=", content)
        record.save!
      end

      # Clean up records whose source file no longer exists
      model_class.where.not(key => seen_keys).destroy_all
    end

    def self.sync_all!
      models = ActiveRecord::Base.descendants.select do |klass|
        klass.respond_to?(:filepress_options)
      end

      models.each { |model| sync!(model) }
    end
  end

  module ModelExt
    def filepress_model(path: nil, glob: "*.md", key: :slug, content_attribute: :content)
      class_attribute :filepress_options, instance_accessor: false, default: {}

      self.filepress_options = {
        path: path || "app/content/#{name.underscore.pluralize}",
        glob: glob,
        key: key,
        content_attribute: content_attribute
      }
    end
  end
end

ActiveSupport.on_load(:active_record) do
  extend Filepress::ModelExt
end

if defined?(Rake::Task)
  namespace :filepress do
    desc "Sync all filepress-backed models"
    task sync: :environment do
      Rails.application.eager_load!
      Filepress::Syncer.sync_all!
    end
  end
end
