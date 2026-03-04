require "filepress/version"
require "filepress/engine"
require "filepress/file_parser"
require "filepress/model"
require "filepress/sync"

module Filepress
  class << self
    attr_accessor :app

    def registry
      @registry ||= {}
    end

    def register(model_class, options)
      config = options.merge(model_class: model_class)
      registry[model_class.name] = config

      watch(config[:from], config[:extensions])

      trace = TracePoint.new(:end) do |tp|
        if tp.self == model_class
          trace.disable
          Sync.new(config).perform
        end
      end
      trace.enable
    end

    def watch(dir, extensions)
      return unless watched.add?(dir)

      app.reloaders << app.config.file_watcher.new([], { dir => extensions }) { sync }
    end

    def sync
      registry.each_value do |config|
        Sync.new(config).perform
      end
    end

    private

    def watched
      @watched ||= Set.new
    end
  end
end
