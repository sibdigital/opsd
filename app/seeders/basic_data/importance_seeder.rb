#-- encoding: UTF-8
# This file written by BBM
# 25/04/2019

module BasicData
  class ImportanceSeeder < Seeder
    def seed_data!
      Importance.transaction do
        data.each do |attributes|
          Importance.create!(attributes)
        end
      end
    end

    def applicable?
      Importance.all.empty?
    end

    def not_applicable_message
      'Skipping importance as there are already some configured'
    end

    def data
      [
        { name: I18n.t(:default_impotance_low), position: 1, is_default: false },
        { name: I18n.t(:default_impotance_critical), position: 2, is_default: false  }#,
        #{ name: I18n.t(:default_possibility_normal), position: 3, is_default: true },
        #{ name: I18n.t(:default_possibility_high), position: 4, is_default: false },
        #{ name: I18n.t(:default_possibility_very_high), position: 5, is_default: false }
      ]
    end
  end
end
