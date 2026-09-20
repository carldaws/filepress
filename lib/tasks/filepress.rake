namespace :filepress do
  desc "Sync content files into the database"
  task sync: :environment do
    Filepress.sync
  end
end
