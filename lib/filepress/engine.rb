module Filepress
  class Engine < ::Rails::Engine
    initializer "filepress.model" do
      ActiveSupport.on_load(:active_record) do
        extend Filepress::Model
      end
    end

    initializer "filepress.file_watcher" do |app|
      content_path = app.root.join("app", "content")

      app.config.after_initialize do
        if content_path.exist?
          extensions = Filepress.watched_extensions
          app.reloaders << app.config.file_watcher.new([], { content_path.to_s => extensions }) do
            Filepress.sync
          end
        end
      end
    end
  end
end
