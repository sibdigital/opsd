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
            @projects = [params[:project]]
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
              if raion_id && raion_id != '0'
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
                curator = project.curator
                stroka['kurator'] = curator.empty? ? '' : curator['fio']
                stroka['kurator_id'] = curator.empty? ? '' : curator['id']
                rukovoditel = project.rukovoditel
                stroka['rukovoditel'] = rukovoditel.empty? ? '' : rukovoditel['fio']
                stroka['rukovoditel_id'] = rukovoditel.empty? ? '' : rukovoditel['id']
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
                  unless project == 0
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
                p = Project.find(@projects[0])
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
              targets = Target.where("type_id != ?", TargetType.where(name: I18n.t('targets.target')).first.id)
              # targets = targets.where("project_id in (" + @projects.join(",") + ")").map(&:id)
              projects = Project.where("id in (" + @projects.join(",") + ")")
              slice_fact_now = LastFactTarget.get_now(@projects.join(","))
              #slice_fact_prev = LastFactTarget.get_previous_quarter(@projects.join(","))
              slice_fact_prev_year = LastFactTarget.get_by_date(@projects.join(","), Time.now.beginning_of_year - 1.day)
              slice_plan_prev_year = LastPlanTarget.get_by_date(@projects.join(","), Time.now.end_of_year - 1.day)
              #fact_now_year = 1
              #fact_next_year = 1
              #slice_fact_now_I = LastFactTarget.get_by_date(@projects.join(","), Time.now.beginning_of_year)
              #slice_fact_now_II = LastFactTarget.get_by_date(@projects.join(","), Time.now.beginning_of_year + 3.month)
              #slice_fact_now_III = LastFactTarget.get_by_date(@projects.join(","), Time.now.beginning_of_year + 6.month)
              #slice_fact_now_IV = LastFactTarget.get_by_date(@projects.join(","), Time.now.beginning_of_year + 9.month)
              #slice_fact_next_I = LastFactTarget.get_by_date(@projects.join(","), Time.now.end_of_year + 1.day)
              #slice_fact_next_II = LastFactTarget.get_by_date(@projects.join(","), Time.now.end_of_year + 3.month + 1.day)
              #slice_fact_next_III = LastFactTarget.get_by_date(@projects.join(","), Time.now.end_of_year + 6.mo  nth + 1.day)
              #slice_fact_next_IV = LastFactTarget.get_by_date(@projects.join(","), Time.now.end_of_year + 9.month + 1.day)
              plan_fact_current_year = PlanFactQuarterlyTargetValue.where(project_id: @projects, year: Time.now.beginning_of_year.year).as_json
              plan_fact_next_year = PlanFactQuarterlyTargetValue.where(project_id: @projects, year: (Time.now.end_of_year + 1.day).year).as_json
              # slice_fact_next = LastFactTarget.get_next_quarter(@projects.join(","))
              slice_plan_now = FirstPlanTarget.get_now(@projects.join(","))
              #slice_plan_prev = FirstPlanTarget.get_previous_quarter(@projects.join(","))
              #slice_plan_next = FirstPlanTarget.get_next_quarter(@projects.join(","))
              #slice_plan_end = LastPlanTarget.get_ends(@projects.join(","))

              # pfqtv = PlanFactQuarterlyTargetValue.where("target_id in (" + targets.join(",") + ") and project_id in (" + @projects.join(",") + ")")
              # pfqtv = pfqtv.offset(to_i_or_nil(params[:offset])) if params[:offset].present?
              result = []
              projects.each do |project|
                hash = Hash.new
                hash['_type'] = 'Project'
                hash['project_id'] = project.id
                hash['name'] = project.name
                hash['identifier'] = project.identifier
                hash['parentId'] = project.federal_project_id || project.national_project_id || 0
                hash['federal_id'] = project.federal_project_id || 0
                hash['national_id'] = project.national_project_id || 0
                hash['targets'] = []
                targets.where(project_id: project.id).each do |t|
                  stroka = Hash.new
                  stroka['_type'] = 'PlanFact QuarterlyTargetValue'
                  stroka['name'] = t.name
                  stroka['target_id'] = t.id
                  stroka['basic_value'] = t.basic_value
                  stroka['unit'] = t.measure_unit.to_s
                  stroka['otvetstvenniy_id'] = t.resultassigned ? t.resultassigned.id : ''
                  stroka['otvetstvenniy'] = t.resultassigned ? t.resultassigned.fio : ''
                  target_plan_now = slice_plan_now.find {|slice| slice["target_id"] == t.id}
                  #target_plan_prev = slice_plan_prev.find {|slice| slice["target_id"] == t.id}
                  #target_plan_next = slice_plan_next.find {|slice| slice["target_id"] == t.id}
                  #target_plan_end = slice_plan_end.find {|slice| slice["target_id"] == t.id}
                  target_fact_now = slice_fact_now.select {|slice| slice["target_id"] == t.id}
                  #target_fact_prev = slice_fact_prev.select {|slice| slice["target_id"] == t.id}
                  target_plan_prev_year = slice_plan_prev_year.find {|slice| slice["target_id"] == t.id}
                  target_fact_prev_year = slice_fact_prev_year.find {|slice| slice["target_id"] == t.id}
                  target_plan_fact_current_year = plan_fact_current_year.find {|slice| slice["target_id"] == t.id}
                  target_plan_fact_next_year = plan_fact_next_year.find {|slice| slice["target_id"] == t.id}
                  #target_slice_fact_now_I = slice_fact_now_I.find {|slice| slice["target_id"] == t.id}
                  #target_slice_fact_now_II = slice_fact_now_II.find {|slice| slice["target_id"] == t.id}
                  #target_slice_fact_now_III = slice_fact_now_III.find {|slice| slice["target_id"] == t.id}
                  #target_slice_fact_now_IV = slice_fact_now_IV.find {|slice| slice["target_id"] == t.id}
                  #target_slice_fact_next_I = slice_fact_next_I.find {|slice| slice["target_id"] == t.id}
                  #target_slice_fact_next_II = slice_fact_next_II.find {|slice| slice["target_id"] == t.id}
                  #target_slice_fact_next_III = slice_fact_next_III.find {|slice| slice["target_id"] == t.id}
                  #target_slice_fact_next_IV = slice_fact_next_IV.find {|slice| slice["target_id"] == t.id}

                  #stroka['target_prev'] = target_plan_prev.nil? ? 0.0 : target_plan_prev["value"].nil? ? 0.0 : target_plan_prev["value"].to_f
                  stroka['target_now'] = target_plan_now.nil? ? 0.0 : target_plan_now["value"].nil? ? 0.0 : target_plan_now["value"].to_f
                  #stroka['target_next'] = target_plan_next.nil? ? 0.0 : target_plan_next["value"].nil? ? 0.0 : target_plan_next["value"].to_f
                  #stroka['target_end'] = target_plan_end.nil? ? 0.0 : target_plan_end["value"].nil? ? 0.0 : target_plan_end["value"].to_f
                  stroka['target_prev_year_plan'] = target_plan_prev_year.nil? ? 0.0 : target_plan_prev_year["value"].nil? ? 0.0 : target_plan_prev_year["value"].to_f
                  stroka['target_prev_year_fact'] = target_fact_prev_year.nil? ? 0.0 : target_fact_prev_year["value"].nil? ? 0.0 : target_fact_prev_year["value"].to_f
                  target_plan_current_year = if target_plan_fact_current_year.nil?
                                               [0.0, 0.0, 0.0, 0.0]
                                             else
                                               [target_plan_fact_current_year["target_quarter1_value"].nil? ? 0.0 : target_plan_fact_current_year["target_quarter1_value"].to_f,
                                                target_plan_fact_current_year["target_quarter2_value"].nil? ? 0.0 : target_plan_fact_current_year["target_quarter2_value"].to_f,
                                                target_plan_fact_current_year["target_quarter3_value"].nil? ? 0.0 : target_plan_fact_current_year["target_quarter3_value"].to_f,
                                                target_plan_fact_current_year["target_quarter4_value"].nil? ? 0.0 : target_plan_fact_current_year["target_quarter4_value"].to_f]
                                             end
                  stroka['target_current_year_plan'] = target_plan_current_year
                  target_plan_next_year = if target_plan_fact_next_year.nil?
                                            [0.0, 0.0, 0.0, 0.0]
                                          else
                                            [target_plan_fact_next_year["target_quarter1_value"].nil? ? 0.0 : target_plan_fact_next_year["target_quarter1_value"].to_f,
                                             target_plan_fact_next_year["target_quarter2_value"].nil? ? 0.0 : target_plan_fact_next_year["target_quarter2_value"].to_f,
                                             target_plan_fact_next_year["target_quarter3_value"].nil? ? 0.0 : target_plan_fact_next_year["target_quarter3_value"].to_f,
                                             target_plan_fact_next_year["target_quarter4_value"].nil? ? 0.0 : target_plan_fact_next_year["target_quarter4_value"].to_f]
                                          end
                  stroka['target_next_year_plan'] = target_plan_next_year
                  target_fact_current_year = if target_plan_fact_current_year.nil?
                                               [0.0, 0.0, 0.0, 0.0]
                                             else
                                               [target_plan_fact_current_year["fact_quarter1_value"].nil? ? 0.0 : target_plan_fact_current_year["fact_quarter1_value"].to_f,
                                                target_plan_fact_current_year["fact_quarter2_value"].nil? ? 0.0 : target_plan_fact_current_year["fact_quarter2_value"].to_f,
                                                target_plan_fact_current_year["fact_quarter3_value"].nil? ? 0.0 : target_plan_fact_current_year["fact_quarter3_value"].to_f,
                                                target_plan_fact_current_year["fact_quarter4_value"].nil? ? 0.0 : target_plan_fact_current_year["fact_quarter4_value"].to_f]
                                             end
                  #target_fact_current_year =[target_slice_fact_now_I.nil? ? 0.0 : target_slice_fact_now_I["value"].nil? ? 0.0 : target_slice_fact_now_I["value"].to_f,
                  #                           target_slice_fact_now_II.nil? ? 0.0 : target_slice_fact_now_II["value"].nil? ? 0.0 : target_slice_fact_now_II["value"].to_f,
                  #                           target_slice_fact_now_III.nil? ? 0.0 : target_slice_fact_now_III["value"].nil? ? 0.0 : target_slice_fact_now_III["value"].to_f,
                  #                           target_slice_fact_now_IV.nil? ? 0.0 : target_slice_fact_now_IV["value"].nil? ? 0.0 : target_slice_fact_now_IV["value"].to_f]
                  stroka['target_current_year_fact'] = target_fact_current_year
                  target_fact_next_year = if target_plan_fact_next_year.nil?
                                            [0.0, 0.0, 0.0, 0.0]
                                          else
                                            [target_plan_fact_next_year["fact_quarter1_value"].nil? ? 0.0 : target_plan_fact_next_year["fact_quarter1_value"].to_f,
                                             target_plan_fact_next_year["fact_quarter2_value"].nil? ? 0.0 : target_plan_fact_next_year["fact_quarter2_value"].to_f,
                                             target_plan_fact_next_year["fact_quarter3_value"].nil? ? 0.0 : target_plan_fact_next_year["fact_quarter3_value"].to_f,
                                             target_plan_fact_next_year["fact_quarter4_value"].nil? ? 0.0 : target_plan_fact_next_year["fact_quarter4_value"].to_f]
                                          end
                  #target_fact_next_year =[target_slice_fact_next_I.nil? ? 0.0 : target_slice_fact_next_I["value"].nil? ? 0.0 : target_slice_fact_next_I["value"].to_f,
                  #                        target_slice_fact_next_II.nil? ? 0.0 : target_slice_fact_next_II["value"].nil? ? 0.0 : target_slice_fact_next_II["value"].to_f,
                  #                        target_slice_fact_next_III.nil? ? 0.0 : target_slice_fact_next_III["value"].nil? ? 0.0 : target_slice_fact_next_III["value"].to_f,
                  #                        target_slice_fact_next_IV.nil? ? 0.0 : target_slice_fact_next_IV["value"].nil? ? 0.0 : target_slice_fact_next_IV["value"].to_f]
                  stroka['target_next_year_fact'] = target_fact_next_year
                  #stroka['fact_prev'] = target_fact_prev.sum { |f| f["value"].nil? ? 0 : f["value"].to_f }
                  stroka['fact_now'] = target_fact_now.sum { |f| f["value"].nil? ? 0 : f["value"].to_f }

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
