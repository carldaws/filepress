ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"

ActiveSupport::TestCase.fixture_paths = [File.expand_path("fixtures", __dir__)]

class ActiveSupport::TestCase
  setup do
    Filepress.registry.clear
  end
end
