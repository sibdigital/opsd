
#-- encoding: UTF-8
# This file written by XCC
# 22/06/2019

module BasicData
  class PeriodSeeder < Seeder
    def seed_data!
      Period.transaction do
        data.each do |attributes|
          Period.create!(attributes)
        end
      end
    end

    def applicable?
      Period.all.empty?
    end

    def not_applicable_message
      'Skipping periods as there are already some configured'
    end

    def data

      [
        { name: I18n.t(:default_period_daily), position: 1, type: "Period", active: true, is_default: false},
        { name: I18n.t(:default_period_weekly), position: 2, type: "Period", active: true, is_default: false},
        { name: I18n.t(:default_period_monthly), position: 3, type: "Period", active: true, is_default: true},
        { name: I18n.t(:default_period_quarterly), position: 4, type: "Period", active: true, is_default: false},
        { name: I18n.t(:default_period_yearly), position: 5, type: "Period", active: true, is_default: false}
      ]

    end

  end
end
