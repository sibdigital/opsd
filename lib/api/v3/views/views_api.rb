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
module API
  module V3
    module Views
      class ViewsAPI < ::API::OpenProjectAPI
        helpers ::API::Utilities::ParamsHelper
        helpers ::API::V3::Utilities::RoleHelper

        before do
          @projects = [0]
          if params[:project].present?
            @projects << params[:project]
          else
            Project.where(type: 'project').visible_by(current_user).each do |project|
              exist = which_role(project, current_user, global_role)
              if exist and project.visible? current_user
                @projects << project.id
              end
            end
          end
        end

        resources :views do
          resources :work_package_stat_by_proj_view do
            get do
              meropriyatie = Type.find_by name: I18n.t(:default_type_task)
              kt = Type.find_by name: I18n.t(:default_type_milestone)
              raion_id = params[:raion]
              if raion_id
                rprojects = Raion.projects_by_id(raion_id, @projects).map {|p| p.id}
                rprojects = rprojects.empty? ? [0] : rprojects #Временное решение, необходимо обдумать. Проблема возникает когда в районе нет проектов, так как возвращается пустой список
                records_array = ActiveRecord::Base.connection.execute <<~SQL
                  select p.id, p1.preds, p1.prosr, p1.riski, p2.ispolneno, p2.all_wps from
                      (select * from projects where id in (#{rprojects.join(",")}))as p
                  left join
                      (select project_id, sum(preds) as preds, sum(prosr) as prosr, sum(riski) as riski
                      from (
                               select wp.project_id,
                                      case when wp.days_to_due >= 0 and wp.days_to_due <= 14 and wp.raion_id = #{raion_id} and wp.type_id = #{meropriyatie.id} and wp.ispolneno = false then 1 else 0 end as preds,
                                      case when wp.days_to_due < 0 and wp.raion_id = #{raion_id} and wp.type_id = #{kt.id} and wp.ispolneno = false then 1 else 0 end as prosr,
                                      case when wp.raion_id = #{raion_id} then wp.created_problem_count else 0 end as riski
                               from v_work_package_ispoln_stat as wp
                               where wp.raion_id = #{raion_id}
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
                      (select * from projects where id in (#{@projects.join(",")}))as p
                  left join
                      (select project_id, sum(preds) as preds, sum(prosr) as prosr, sum(created_problem_count) as riski
                      from (
                               select wp.project_id,
                                      case when wp.days_to_due >= 0 and wp.days_to_due <= 14 and wp.type_id = #{meropriyatie.id} and wp.ispolneno = false then 1 else 0 end as preds,
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
              proj_arr = Project.where(id: @projects).to_a

              records_array.map do |arr|
                stroka = Hash.new
                stroka['_type'] = 'Project'
                stroka['project_id'] = arr['id']
                project = proj_arr.select {|p| p.id == arr['id']}.first# Project.find(arr['id'])
                stroka['name'] = project.name
                stroka['identifier'] = project.identifier
                stroka['parentId'] = project.federal_project_id || project.national_project_id || 0
                stroka['federal_id'] = project.federal_project_id || 0
                stroka['national_id'] = project.national_project_id || 0
                stroka['kurator'] = project.curator.empty? ? '' : project.curator['fio']
                stroka['kurator_id'] = project.curator.empty? ? '' : project.curator['id']
                stroka['rukovoditel'] = project.rukovoditel.empty? ? '' : project.rukovoditel['fio']
                stroka['rukovoditel_id'] = project.rukovoditel.empty? ? '' : project.rukovoditel['id']
                stroka['budget_fraction'] = project.get_budget_fraction raion_id
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

          resources :risk_problem_stat_view do
            get do
              rps = RiskProblemStat
                .joins(:project)
                .where("project_id in (" + @projects.join(",")+ ")")
              rps = params[:national] == '0' ? rps.where("projects.national_project_id is null") : rps.where(projects:{national_project_id: params[:national]}) if params[:national].present?
              rps = rps.where(type: params[:filter]) if params[:filter].present? and params[:filter] != 'all'
              result = Hash.new
              result['_type'] = 'Collection'
              result['total'] = rps.count
              result['pageSize'] = params[:offset].present? ? 20 : rps.count
              result['offset'] = params[:offset].present? ? to_i_or_nil(params[:offset]) : 1
              rps = rps.limit(20).offset((to_i_or_nil(params[:offset]) - 1) * 20) if params[:offset].present?
              result['count'] = rps.count
              collection = []
              if rps.count == 0
                @projects.each do |project|
                  unless project.zero?
                    p = Project.find(project)
                    hash = Hash.new
                    hash['_type'] = 'Project'
                    hash['project_id'] = p.id
                    hash['name'] = p.name
                    hash['parentId'] = p.federal_project_id || p.national_project_id || 0
                    hash['identifier'] = p.identifier
                    hash['federal_id'] = p.federal_project_id || 0
                    hash['national_id'] = p.national_project_id || 0
                    hash['problems'] = []
                    collection << hash
                  end
                end
              end
              rps.group_by(&:project_id).each do |project, arr|
                hash = Hash.new
                hash['_type'] = 'Project'
                hash['project_id'] = project
                p = Project.find(project)
                hash['name'] = p.name
                hash['parentId'] = p.federal_project_id || p.national_project_id || 0
                hash['identifier'] = p.identifier
                hash['federal_id'] = p.federal_project_id || 0
                hash['national_id'] = p.national_project_id || 0
                hash['problems'] = []
                arr.each do |row|
                  stroka = Hash.new
                  stroka['_type'] = 'RiskProblemStat'
                  stroka['work_package_id'] = row.work_package_id
                  stroka['project_id'] = row.project_id
                  wpp = WorkPackageProblem.find(row.id)
                  stroka['solution_date'] = wpp.solution_date
                  stroka['risk_or_problem'] = wpp.risk ? wpp.risk.name : wpp.description
                  stroka['user_creator'] = wpp.user_creator ? wpp.user_creator.fio : ''
                  stroka['user_source'] = wpp.user_source ? wpp.user_source.fio : ''
                  stroka['importance_id'] = row.importance_id
                  stroka['importance'] = row.importance
                  stroka['type'] = row.type
                  hash['problems'] << stroka
                end
                collection << hash
              end
              result['elements'] = collection
              result
            end
          end

          resources :quartered_work_package_targets_with_quarter_groups_view do
            get do
              qwptwqg = WorkPackageQuarterlyTarget.where("year = date_part('year', CURRENT_DATE) and project_id in (" + @projects.join(",")+ ")")
              qwptwqg = params[:national] == '0' ? qwptwqg.where("national_project_id is null") : qwptwqg.where(national_project_id: params[:national]) if params[:national].present?
              result = Hash.new
              result['_type'] = 'Collection'
              result['total'] = qwptwqg.count
              result['pageSize'] = params[:offset].present? ? 20 : qwptwqg.count
              result['offset'] = params[:offset].present? ? to_i_or_nil(params[:offset]) : 1
              qwptwqg = qwptwqg.limit(20).offset((to_i_or_nil(params[:offset]) - 1) * 20) if params[:offset].present?
              result['count'] = qwptwqg.count
              collection = []
              if qwptwqg.count == 0
                p = Project.find(@projects[1])
                hash = Hash.new
                hash['_type'] = 'Project'
                hash['project_id'] = p.id
                hash['name'] = p.name
                hash['identifier'] = p.identifier
                hash['parentId'] = p.federal_project_id || p.national_project_id || 0
                hash['federal_id'] = p.federal_project_id || 0
                hash['national_id'] = p.national_project_id || 0
                hash['curator'] = p.curator.empty? ? '' : p.curator['fio']
                hash['curator_id'] = p.curator.empty? ? '' : p.curator['id']
                hash['rukovoditel'] = p.rukovoditel.empty? ? '' : p.rukovoditel['fio']
                hash['rukovoditel_id'] = p.rukovoditel.empty? ? '' : p.rukovoditel['id']
                hash['targets'] = []
                collection << hash
              end
              qwptwqg.group_by(&:project_id).each do |project, arr|
                hash = Hash.new
                hash['_type'] = 'Project'
                hash['project_id'] = project
                p = Project.find(project)
                hash['name'] = p.name
                hash['identifier'] = p.identifier
                hash['parentId'] = p.federal_project_id || p.national_project_id || 0
                hash['federal_id'] = p.federal_project_id || 0
                hash['national_id'] = p.national_project_id || 0
                hash['curator'] = p.curator.empty? ? '' : p.curator['fio']
                hash['curator_id'] = p.curator.empty? ? '' : p.curator['id']
                hash['rukovoditel'] = p.rukovoditel.empty? ? '' : p.rukovoditel['fio']
                hash['rukovoditel_id'] = p.rukovoditel.empty? ? '' : p.rukovoditel['id']
                hash['targets'] = []
                arr.group_by(&:target_id).each do |target, subarr|
                  stroka = Hash.new
                  stroka['_type'] = 'Target'
                  stroka['target_id'] = target
                  t = Target.find(target)
                  stroka['name'] = t.name
                  stroka['work_packages'] = []
                  subarr.each do |row|
                    #+-tan исправлена опечатка по смыслу не find(row.id), a find(row.work_package_id)
                    wp = WorkPackage.find_by(id: row.work_package_id)
                    if wp
                      quarter = Hash.new
                      quarter['_type'] = 'WorkPackageQuarterlyTarget'
                      quarter['work_package_id'] = row.work_package_id
                      quarter['subject'] = wp.subject
                      quarter['assignee'] = wp.assigned_to ? wp.assigned_to.fio : ''
                      quarter['assignee_id'] = wp.assigned_to ? wp.assigned_to.id : ''
                      case DateTime.now.month
                      when 1, 2, 3
                        quarter['plan'] = row.quarter1_plan_value
                        quarter['fact'] = row.quarter1_value
                      when 4, 5, 6
                        quarter['plan'] = row.quarter2_plan_value
                        quarter['fact'] = row.quarter2_value
                      when 7, 8, 9
                        quarter['plan'] = row.quarter3_plan_value
                        quarter['fact'] = row.quarter3_value
                      when 10, 11, 12
                        quarter['plan'] = row.quarter4_plan_value
                        quarter['fact'] = row.quarter4_value
                      end
                      stroka['work_packages'] << quarter
                    end
                  end
                  hash['targets'] << stroka
                end
                collection << hash
              end
              result['elements'] = collection
              result
            end
          end

          resources :work_package_ispoln_stat_view do
            get do
              wpis = WorkPackageIspolnStat.where("project_id in (" + @projects.join(",")+ ")")
              wpis = params[:national] == '0' ? wpis.where("national_project_id is null") : wpis.where(national_project_id: params[:national]) if params[:national].present?
              wpis = wpis.where("days_to_due > 0 and days_to_due < ?", params[:limit]) if params[:limit].present?
              case params[:filter]
              when 'vsrok'
                wpis = wpis.where(ispolneno_v_srok: true)
              when 'sopozdaniem'
                wpis = wpis.where(ispolneno_v_srok: false, ispolneno: true)
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
                hash['parentId'] = p.federal_project_id || p.national_project_id || 0
                hash['federal_id'] = p.federal_project_id || 0
                hash['national_id'] = p.national_project_id || 0
                hash['work_packages'] = []
                arr.each do |row|
                  stroka = Hash.new
                  stroka['_type'] = 'WorkPackageIspolnStat'
                  stroka['work_package_id'] = row.id
                  stroka['project_id'] = project
                  stroka['subject'] = row.subject
                  stroka['otvetstvenniy'] = row.assigned_to ? row.assigned_to.fio : ''
                  stroka['otvetstvenniy_id'] = row.assigned_to ? row.assigned_to.id : ''
                  stroka['due_date'] = row.due_date
                  stroka['status_name'] = row.status_name
                  stroka['created_problem_count'] = row.created_problem_count
                  stroka['fakt_ispoln'] = row.fact_due_date ? row.fact_due_date.to_s : nil
                  stroka['ispolneno'] = row.ispolneno
                  stroka['ispolneno_v_srok'] = row.ispolneno_v_srok
                  stroka['ne_ispolneno'] = row.ne_ispolneno
                  stroka['est_riski'] = row.est_riski
                  stroka['v_rabote'] = row.v_rabote
                  stroka['days_to_due'] = row.days_to_due
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
              pfqtv = PlanFactQuarterlyTargetValue.where("year = date_part('year', CURRENT_DATE) and project_id in (" + @projects.join(",")+ ")")
              pfqtv = pfqtv.offset(to_i_or_nil(params[:offset])) if params[:offset].present?
              result = []
              pfqtv.group_by(&:project_id).each do |project, arr|
                hash = Hash.new
                hash['_type'] = 'Project'
                hash['project_id'] = project
                p = Project.find(project)
                hash['name'] = p.name
                hash['identifier'] = p.identifier
                hash['parentId'] = p.federal_project_id || p.national_project_id || 0
                hash['federal_id'] = p.federal_project_id || 0
                hash['national_id'] = p.national_project_id || 0
                hash['targets'] = []
                arr.each do |row|
                  stroka = Hash.new
                  stroka['_type'] = 'PlanFactQuarterlyTargetquartered_work_package_targets_with_quarter_groups_viewValue'
                  target = Target.find(row.target_id)
                  stroka['name'] = target.name
                  stroka['target_id'] = row.target_id
                  stroka['target_year_value'] = row.target_year_value
                  stroka['fact_year_value'] = row.fact_year_value
                  stroka['otvetstvenniy_id'] = target.resultassigned ? target.resultassigned.id : ''
                  stroka['otvetstvenniy'] = target.resultassigned ? target.resultassigned.fio : ''

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
