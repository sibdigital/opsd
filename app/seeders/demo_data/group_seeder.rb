#-- encoding: UTF-8
# This file written by KNM
# 22/06/2019

module DemoData
  class GroupSeeder < Seeder
    def seed_data!
      Group.transaction do
        data.each do |attributes|
          Group.create!(attributes)
        end
      end
      @group = Group.includes(:users).find_by(lastname: I18n.t(:label_user_all))
      @users = User.includes(:memberships).where(type: "User")
      @group.users << @users
    end

    def applicable?
      Group.all.empty?
    end

    def not_applicable_message
      'Skipping importance as there are already some configured'
    end

    def data
      [
        { lastname: I18n.t(:label_user_all), status: 1, direct_manager_id: 2}
      ]
    end
  end
end

