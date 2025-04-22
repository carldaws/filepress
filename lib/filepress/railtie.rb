module Filepress
  class Railtie < ::Rails::Railtie
    ActiveSupport.on_load(:active_record) do
      extend Filepress::Model
    end

    rake_tasks do
      Dir[File.expand_path("../tasks/**/*.rake", __dir__)].each { |f| load f }
    end
  end
end
