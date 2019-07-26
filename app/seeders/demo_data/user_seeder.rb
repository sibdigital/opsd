#-- encoding: UTF-8
# This file written by BBM
# 26/04/2019

module DemoData
  class UserSeeder < Seeder

    def initialize; end

    def seed_data!
      users = translate_with_base_url("seeders.demo_data.users")


      users.each do |attributes|
        print '.'
        user = new_user attributes
        unless user.save! validate: false
          puts 'Seeding admin failed:'
          user.errors.full_messages.each do |msg|
            puts "  #{msg}"
          end
        end
      end


    end

    private

    def new_user(attributes)
      User.new.tap do |user|
        user.login  =        attributes[:login]
        user.password  =         attributes[:password]
        user.firstname  =   attributes[:firstname]
        user.lastname  =   attributes[:lastname]
        user.patronymic  = attributes[:patronymic]
        user.mail  = attributes[:mail]
        user.status  = attributes[:status]
        user.type  = attributes[:type]
        user.mail_notification  = attributes[:mail_notification]
        user.language  = I18n.locale.to_s
        user.force_password_change  = false
      end
    end


    def work_package_by_subject(subject)
      np = WorkPackage.find_by(subject: subject)
      if np != nil
        np.id
      end
    end

    def project_by_name(name)
      np = Project.find_by(name: name)
      if np != nil
        np.id
      end
    end

    def target_by_name(name)
      np = Target.find_by(name: name)
      if np != nil
        np.id
      end
    end
  end
end
