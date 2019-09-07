#-- encoding: UTF-8
# This file written by BBM
# 26/04/2019

module DemoData
  class NationalProjectSeeder < Seeder

    def initialize; end

    def seed_data!
      # national_projects = translate_with_base_url("seeders.demo_data.national_projects")
      #
      # national_projects.each do |attributes|
      #   print '.'
      #   tr_attr = national_project_attributes attributes
      #   national_project = NationalProject.create tr_attr
      # end
      #
      # federal_projects = translate_with_base_url("seeders.demo_data.federal_projects")
      #
      # federal_projects.each do |attributes|
      #   print '.'
      #   tr_attr = federal_project_attributes attributes
      #   national_project = NationalProject.create tr_attr
      # end
    end

    private

    def national_project_attributes(attributes)
      {
        name:         attributes[:name],
        type:         attributes[:type],
        leader_position:    attributes[:leader_position],
        curator_position:   attributes[:curator_position],
        start_date: Date.new(2019, 1, 1),
        due_date:   Date.new(2024, 12, 31)
      }
    end

    def federal_project_attributes(attributes)
      {
        name:         attributes[:name],
        type:         attributes[:type],
        leader_position:    attributes[:leader_position],
        curator_position:   attributes[:curator_position],
        start_date: Date.new(2019, 2, 1),
        due_date:   Date.new(2024, 12, 31),
        parent_id: np_by_name(attributes[:parent])
      }
    end

    def np_by_name(np_name)
      np = NationalProject.find_by(name: np_name)
      if np != nil
        np.id
      end
    end
  end
end
