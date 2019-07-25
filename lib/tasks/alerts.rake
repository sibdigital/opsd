namespace :alerts do
  desc "TODO"
  task start: :environment do

    AlertsController.new.find_work_packages

  end

end
