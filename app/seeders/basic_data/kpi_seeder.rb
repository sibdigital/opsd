#-- encoding: UTF-8
# This file written by BAN
# 08/07/2019

module BasicData
  class KeyPerformanceIndicatorSeeder < Seeder
    def seed_data!
      KeyPerformanceIndicator.transaction do
        data.each do |attributes|
          KeyPerformanceIndicator.create!(attributes)
        end
      end
    end

    def applicable?
      KeyPerformanceIndicator.all.empty?
    end

    def not_applicable_message
      'Skipping KPI as there are already some configured'
    end

    def data
      [
        { name: I18n.t(:default_kpi_count_opened_project), weight: 1, calc_method: "sum", enable: true },
        { name: I18n.t(:default_kpi_count_support_project), weight: 1, calc_method: "sum", enable: true },
        { name: I18n.t(:default_kpi_count_opened_meeting), weight: 1, calc_method: "sum", enable: true },
        { name: I18n.t(:default_kpi_no_red_kt), weight: 1, calc_method: "sum", enable: true },
        { name: I18n.t(:default_kpi_monitoring), weight: 1, calc_method: "sum", enable: true },
        { name: I18n.t(:default_kpi_closed_project), weight: 1, calc_method: "sum", enable: true },
        { name: I18n.t(:default_kpi_saved_risks), weight: 1, calc_method: "sum", enable: true },
        { name: I18n.t(:default_kpi_minimize_risks), weight: 1, calc_method: "sum", enable: true }
      ]

    end

    def cases_data
      I18n.t(:default_status_not_start)
      [
        { name: I18n.t(:default_kpi_count_opened_project), role: I18n.t(:default_role_project_curator), percent: 10, min_value: 1, max_value: 3,enable: true, period: "Quarter" },
        { name: I18n.t(:default_kpi_count_opened_project), role: I18n.t(:default_role_project_curator), percent: 30, min_value: 4, max_value: 5,enable: true, period: "Quarter" },
        { name: I18n.t(:default_kpi_count_opened_project), role: I18n.t(:default_role_project_head), percent: 10, min_value: 1, max_value: 3,enable: true, period: "Quarter" },
        { name: I18n.t(:default_kpi_count_opened_project), role: I18n.t(:default_role_project_head), percent: 30, min_value: 4, max_value: 5,enable: true, period: "Quarter" },
        { name: I18n.t(:default_kpi_count_opened_project), role: I18n.t(:default_role_project_admin), percent: 10, min_value: 1, max_value: 3,enable: true, period: "Quarter" },
        { name: I18n.t(:default_kpi_count_opened_project), role: I18n.t(:default_role_project_admin), percent: 30, min_value: 4, max_value: 5,enable: true, period: "Quarter" },

      ]

    end

  end
end
