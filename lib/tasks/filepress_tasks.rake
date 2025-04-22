namespace :filepress do
  desc "Synchronise Filepress models"
  task sync: :environment do
    Filepress.sync
  end
end
