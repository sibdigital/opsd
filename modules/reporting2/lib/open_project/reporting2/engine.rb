#-- copyright
# OpenProject Reporting Plugin
#
# Copyright (C) 2010 - 2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#++

module OpenProject::Reporting2
  class Engine < ::Rails::Engine
    engine_name :openproject_reporting2

    include OpenProject::Plugins::ActsAsOpEngine

    register 'openproject-reporting2',
             author_url: 'http://finn.de',
             requires_openproject: '>= 4.0.0' do

      view_actions = [:index, :show, :drill_down, :available_values, :display_report_list]
      edit_actions = [:create, :update, :rename, :destroy]

      #register reporting_module including permissions
      project_module :reporting_module2 do
        permission :save_target_reports, { target_reports: edit_actions }
        permission :save_private_target_reports, { target_reports: edit_actions }
      end

      #register additional permissions for viewing time and cost entries through the CostReportsController
      #zbd(
      view_actions.each do |action|
        Redmine::AccessControl.permission(:view_work_package_targets).actions << "target_reports/#{action}"
        # Redmine::AccessControl.permission(:view_own_time_entries).actions << "target_reports/#{action}"
        # Redmine::AccessControl.permission(:view_cost_entries).actions << "target_reports/#{action}"
        # Redmine::AccessControl.permission(:view_own_cost_entries).actions << "target_reports/#{action}"
      end
      # )

      #menu extensions
      #zbd(
      menu :project_menu, :target_reports,
           { controller: '/target_reports', action: 'index' },
           param: :project_id,
           caption: :target_reports_title,
           if: Proc.new { |project| project.module_enabled?(:reporting_module2) },
           icon: 'icon2 icon-cost-reports',
           parent: :reports
      # )

    end

    initializer "reporting2.register_hooks" do
      # don't use require_dependency to not reload hooks in development mode
      require 'open_project/reporting2/hooks'
    end

    initializer 'reporting2.precompile_assets' do
      Rails.application.config.assets.precompile += %w(
        reporting_engine/reporting_engine.css
        reporting_engine/reporting_engine.js
      )

      # Without this, tablesorter's assets are not found.
      # This should actually be done by rails itself when one adds the gem to the gemspec.
      Rails.application.config.assets.paths << Gem.loaded_specs['jquery-tablesorter'].full_gem_path + '/vendor/assets/javascripts'
    end

    config.to_prepare do
      require_dependency 'report/walker'
      require_dependency 'report/transformer'
      require_dependency 'widget/entry_table'
      # require_dependency 'widget/settings_patch'
      require_dependency 'target_query/group_by'
      require_dependency 'target_query/filter'
    end

    assets %w(reporting2/reporting.css
              reporting2/reporting.js)

    # patches %i[TimelogController CustomFieldsController OpenProject::Configuration]
    patches %i[OpenProject::Configuration]
    patch_with_namespace :BasicData, :RoleSeeder
    patch_with_namespace :BasicData, :SettingSeeder
  end
end
