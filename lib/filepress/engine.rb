module Filepress
  class Engine < ::Rails::Engine
    initializer "filepress.model" do
      ActiveSupport.on_load(:active_record) do
        extend Filepress::Model
      end
    end

    initializer "filepress.file_watcher" do |app|
      Filepress.app = app
    end
  end
end
