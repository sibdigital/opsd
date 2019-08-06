namespace :alerts do
  desc "TODO"
  task start: :environment do

    AlertsController.new.notify_by_email
    # Alert.create_new_pop_up_alert(@work_packages.id, "WorkPackages", "Due", User.current.id, User.current.id)

  end

end
