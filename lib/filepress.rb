require "filepress/version"
require "filepress/engine"
require "filepress/file_parser"
require "filepress/model"
require "filepress/sync"

module Filepress
  class << self
    def registry
      @registry ||= {}
    end

    def register(model_class, options)
      config = options.merge(model_class: model_class)
      registry[model_class.name] = config
      Sync.new(config).perform
    end

    def watched_extensions
      exts = registry.values.flat_map { |config| config[:extensions] }.uniq
      exts.empty? ? ["md"] : exts
    end

    def sync
      registry.each_value do |config|
        Sync.new(config).perform
      end
    end
  end
end
