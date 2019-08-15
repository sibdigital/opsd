#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2018 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++

require 'api/v3/views/work_package_stat_representer'
require 'api/v3/views/work_package_stat_collection_representer'
require 'api/v3/views/risk_problem_stat_representer'
require 'api/v3/views/risk_problem_stat_collection_representer'

module API
  module V3
    module Views
      class ViewsAPI < ::API::OpenProjectAPI
        helpers ::API::Utilities::ParamsHelper

        resources :views do
          resources :work_package_stat_view do
            get do
              @wps = WorkPackageStat.all
              WorkPackageStatCollectionRepresenter.new(@wps,
                                                       api_v3_paths.views(work_package_stat_view),
                                                       page: to_i_or_nil(params[:offset]),
                                                       per_page: 20,
                                                       current_user: current_user)
            end
          end

          resources :work_package_stat_by_proj_view do
            get do
              meropriyatie = Type.find_by name: I18n.t(:default_type_task)
              kt = Type.find_by name: I18n.t(:default_type_milestone)
              organization_id = params[:organization]
              if organization_id
                records_array = ActiveRecord::Base.connection.execute <<~SQL
                  select p.id, p1.preds, p1.prosr, p1.riski, p2.ispolneno, p2.all_wps from
                      projects as p
                  left join
                      (select project_id, sum(preds) as preds, sum(prosr) as prosr, sum(riski) as riski
                      from (
                               select wp.project_id,
                                      case when wp.days_to_due > 0 and wp.days_to_due <= 14 and wp.organization_id = #{organization_id} and wp.type_id = #{meropriyatie.id} and wp.ispolneno = false then 1 else 0 end as preds,
                                      case when wp.days_to_due < 0 and wp.organization_id = #{organization_id} and wp.type_id = #{kt.id} and wp.ispolneno = false then 1 else 0 end as prosr,
                                      case when wp.organization_id = #{organization_id} then wp.created_problem_count else 0 end as riski
                               from v_work_package_ispoln_stat as wp
                           ) as slice
                      group by project_id) as p1
                  on p.id = p1.project_id
                  left join
                      (select project_id, sum(ispolneno) as ispolneno, sum(all_work_packages) as all_wps
                      from v_project_ispoln_stat
                      group by project_id) as p2
                  on p.id = p2.project_id
                SQL
              else
                records_array = ActiveRecord::Base.connection.execute <<~SQL
                  select p.id, p1.preds, p1.prosr, p1.riski, p2.ispolneno, p2.all_wps from
                      projects as p
                  left join
                      (select project_id, sum(preds) as preds, sum(prosr) as prosr, sum(created_problem_count) as riski
                      from (
                               select wp.project_id,
                                      case when wp.days_to_due > 0 and wp.days_to_due <= 14 and wp.type_id = #{meropriyatie.id} and wp.ispolneno = false then 1 else 0 end as preds,
                                      case when wp.days_to_due < 0 and wp.type_id = #{kt.id} and wp.ispolneno = false then 1 else 0 end as prosr,
                                      wp.created_problem_count
                               from v_work_package_ispoln_stat as wp
                           ) as slice
                      group by project_id) as p1
                  on p.id = p1.project_id
                  left join
                      (select project_id, sum(ispolneno) as ispolneno, sum(all_work_packages) as all_wps
                      from v_project_ispoln_stat
                      group by project_id) as p2
                  on p.id = p2.project_id
                SQL
              end
              @wps = []
              records_array.map do |arr|
                stroka = Hash.new
                stroka['_type'] = 'Project'
                stroka['project_id'] = arr['id']
                project = Project.find(arr['id'])
                stroka['name'] = project.name
                stroka['identifier'] = project.identifier
                stroka['national_id'] = project.national_project_id || 0
                stroka['kurator'] = project.curator.empty? ? '' : project.curator['fio']
                stroka['kurator_id'] = project.curator.empty? ? '' : project.curator['id']
                stroka['rukovoditel'] = project.rukovoditel.empty? ? '' : project.rukovoditel['fio']
                stroka['rukovoditel_id'] = project.rukovoditel.empty? ? '' : project.rukovoditel['id']
                stroka['budget_fraction'] = project.get_budget_fraction
                stroka['dueDate'] = project.due_date
                stroka['preds'] = arr['preds'] || 0
                stroka['prosr'] = arr['prosr'] || 0
                stroka['riski'] = arr['riski'] || 0
                stroka['ispolneno'] = arr['ispolneno'] || 0
                stroka['all_wps'] = arr['all_wps'] || 0
                @wps << stroka
              end
              @wps
            end
          end

          resources :work_package_ispoln_stat_view do
            get do
              wpis = WorkPackageIspolnStat.all
              wpis = wpis.where(project_id: params[:project]) if params[:project].present? and params[:project]
              wpis = wpis.where("days_to_due > 0 and days_to_due < ?", params[:limit]) if params[:limit].present? and params[:limit]
              case params[:filter]
              # TODO: проверить правильность этих фильтров
              # when 'vsrok'
              #  wpis = wpis.where(v_rabote: true)
              # when 'sopozdaniem'
              #  wpis = wpis.where(v_rabote: true)
              when 'vrabote'
                wpis = wpis.where(v_rabote: true)
              when 'predstoyashie'
                wpis = wpis.where("days_to_due > 0")
              end
              result = Hash.new
              result['_type'] = 'Collection'
              result['total'] = wpis.count
              result['pageSize'] = params[:offset].present? ? 20 : wpis.count
              result['offset'] = params[:offset].present? ? to_i_or_nil(params[:offset]) : 1
              wpis = wpis.limit(20).offset((to_i_or_nil(params[:offset]) - 1) * 20) if params[:offset].present?
              result['count'] = wpis.count
              collection = []
              wpis.group_by(&:project_id).each do |project, arr|
                hash = Hash.new
                hash['_type'] = 'Project'
                hash['project_id'] = project
                p = Project.find(project)
                hash['name'] = p.name
                hash['identifier'] = p.identifier
                hash['national_id'] = p.national_project_id || 0
                hash['work_packages'] = []
                arr.each do |row|
                  stroka = Hash.new
                  stroka['_type'] = 'WorkPackageIspolnStat'
                  stroka['work_package_id'] = row.id
                  stroka['subject'] = row.subject
                  stroka['otvetstvenniy'] = row.assigned_to.fio
                  stroka['otvetstvenniy_id'] = row.assigned_to.id
                  stroka['due_date'] = row.due_date
                  stroka['status_name'] = row.status_name
                  stroka['created_problem_count'] = row.created_problem_count
                  # TODO:Переписать дату факт
                  records_array = ActiveRecord::Base.connection.exec_query <<~SQL
                    select created_at from work_package_journals as wpj
                    inner join journals as j
                    on wpj.journal_id = j.id
                    where journable_type = 'WorkPackage'
                    and journable_id = #{row.id}
                    and status_id = 3
                    order by wpj.id desc
                    limit 1
                  SQL
                  stroka['fakt_ispoln'] = records_array.empty? ? '' : records_array[0]['created_at']
                  hash['work_packages'] << stroka
                end
                collection << hash
              end
              result['elements'] = collection
              result
            end
          end

          resources :plan_fact_quarterly_target_values_view do
            get do
              pfqtv = PlanFactQuarterlyTargetValue.where("year = date_part('year', CURRENT_DATE)")
              pfqtv = pfqtv.where(project_id: params[:project]) if params[:project].present?
              pfqtv = pfqtv.offset(to_i_or_nil(params[:offset])) if params[:offset].present?
              result = []
              pfqtv.group_by(&:project_id).each do |project, arr|
                hash = Hash.new
                hash['_type'] = 'Project'
                hash['project_id'] = project
                p = Project.find(project)
                hash['name'] = p.name
                hash['identifier'] = p.identifier
                hash['national_id'] = p.national_project_id || 0
                hash['targets'] = []
                arr.each do |row|
                  stroka = Hash.new
                  stroka['_type'] = 'PlanFactQuarterlyTargetValue'
                  # wp = WorkPackage.find(row.work_package_id)
                  # stroka['otvetstvenniy'] = wp.assigned_to.fio
                  # stroka['otvetstvenniy_id'] = wp.assigned_to.id
                  stroka['name'] = Target.find(row.target_id).name
                  stroka['target_id'] = row.target_id
                  stroka['target_year_value'] = row.target_year_value
                  stroka['fact_year_value'] = row.fact_year_value
                  stroka['target_quarter1_value'] = row.target_quarter1_value
                  stroka['target_quarter2_value'] = row.target_quarter2_value
                  stroka['target_quarter3_value'] = row.target_quarter3_value
                  stroka['target_quarter4_value'] = row.target_quarter4_value

                  stroka['plan_quarter1_value'] = row.plan_quarter1_value
                  stroka['plan_quarter2_value'] = row.plan_quarter2_value
                  stroka['plan_quarter3_value'] = row.plan_quarter3_value
                  stroka['plan_quarter4_value'] = row.plan_quarter4_value

                  stroka['fact_quarter1_value'] = row.fact_quarter1_value
                  stroka['fact_quarter2_value'] = row.fact_quarter2_value
                  stroka['fact_quarter3_value'] = row.fact_quarter3_value
                  stroka['fact_quarter4_value'] = row.fact_quarter4_value
                  hash['targets'] << stroka
                end
                result << hash
              end
              result
            end
          end
        end
      end
    end
  end
end
