namespace :alerts do
  desc "TODO"
  task start: :environment do

    AlertsController.new.notify_by_email

  end

end
