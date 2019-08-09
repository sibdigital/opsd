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

module API
  module V3
    module Views
      class ViewsAPI < ::API::OpenProjectAPI
        resources :work_package_stat_view do
          get do
            @wps = WorkPackageStat.all
            WorkPackageStatCollectionRepresenter.new(@wps,
                                                     api_v3_paths.work_package_stat_view,
                                                     current_user: current_user)
          end
        end

        resources :work_package_stat_by_proj_view do
          get do
            meropriyatie = Type.find_by name: I18n.t(:default_type_task)
            kt = Type.find_by name: I18n.t(:default_type_milestone)
            organization_id = params['organization']
            if organization_id
              records_array = ActiveRecord::Base.connection.execute <<-SQL
select p.id, p1.preds, p1.prosr, p1.riski, p2.ispolneno, p2.all_wps from
    projects as p
left join
    (select project_id, sum(preds) as preds, sum(prosr) as prosr, sum(riski) as riski
    from (
             select wp.project_id,
                    case when wp.days_to_due > 0 and wp.days_to_due <= 14 and wp.organization_id = #{organization_id} and wp.type_id = #{meropriyatie.id} and wp.ispolneno = false then 1 else 0 end as preds,
                    case when wp.days_to_due < 0 and wp.organization_id = #{organization_id} and wp.type_id = #{kt.id} and wp.ispolneno = false then 1 else 0 end                                    as prosr,
                    case when wp.est_riski = true and wp.organization_id = #{organization_id} then 1 else 0 end                                                                                      as riski
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
              records_array = ActiveRecord::Base.connection.execute <<-SQL
select p.id, p1.preds, p1.prosr, p1.riski, p2.ispolneno, p2.all_wps from
    projects as p
left join
    (select project_id, sum(preds) as preds, sum(prosr) as prosr, sum(riski) as riski
    from (
             select wp.project_id,
                    case when wp.days_to_due > 0 and wp.days_to_due <= 14 and wp.type_id = #{meropriyatie.id} and wp.ispolneno = false then 1 else 0 end as preds,
                    case when wp.days_to_due < 0 and wp.type_id = #{kt.id} and wp.ispolneno = false then 1 else 0 end                                    as prosr,
                    case when wp.est_riski = true then 1 else 0 end                                                                                      as riski
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
              stroka['national_id'] = project.national_project_id || 0;
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
      end
    end
  end
end
