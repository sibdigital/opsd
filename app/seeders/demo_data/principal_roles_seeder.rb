#-- encoding: UTF-8
# zbd
#++
module DemoData
  class PrincipalRolesSeeder < Seeder
    def seed_data!
      data.each do |attributes|
        puts attributes
        id_attributes = {}
        id_attributes[:role_id] = find_role(attributes[:role_name])
        id_attributes[:principal_id] = find_user(attributes[:user_name])
        PrincipalRole.create(id_attributes)
      end
    end

    def data
      [
        { role_name: :default_role_glava_regiona_global, user_name: "tas" },
        { role_name: :default_role_project_activity_coordinator_global, user_name: "zii" }
      ]
    end

    private

    def find_user(user_name)
      user = User.find_by(login: user_name)
      user.id
    end

    def find_role(role_name)
      role = Role.find_by(name: I18n.t(role_name))
      role.id
    end
  end
end
