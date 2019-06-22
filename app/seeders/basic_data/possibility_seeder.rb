#-- encoding: UTF-8
# This file written by BBM
# 25/04/2019

module BasicData
  class PossibilitySeeder < Seeder
    def seed_data!
      Possibility.transaction do
        data.each do |attributes|
          Possibility.create!(attributes)
        end
      end
    end

    def applicable?
      Possibility.all.empty?
    end

    def not_applicable_message
      'Skipping possibilities as there are already some configured'
    end

    def data
      [
        { name: I18n.t(:default_possibility_very_low), position: 1, is_default: false },
        { name: I18n.t(:default_possibility_low), position: 2, is_default: false  },
        { name: I18n.t(:default_possibility_normal), position: 3, is_default: true },
        { name: I18n.t(:default_possibility_high), position: 4, is_default: false },
        { name: I18n.t(:default_possibility_very_high), position: 5, is_default: false }
      ]
    end
  end
end
