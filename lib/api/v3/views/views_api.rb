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
select p.project_id, count(preds) as preds, count (prosr) as prosr, sum(created_problem_count) as problem, ispolneno, all_wps
from (
         select wps.project_id, wps.organization_id, wpx.created_problem_count, wpp.id as preds, wpc.id as prosr
         from v_work_package_stat as wps
                  left join (select v.id, v.project_id from v_work_package_stat as v left join statuses as s on v.status_id = s.id where v.organization_id = #{organization_id} and v.due_date > current_date and v.type_id = 1 and s.is_closed = false) as wpp
                            using (project_id, id)
                  left join (select v.id, v.project_id from v_work_package_stat as v left join statuses as s on v.status_id = s.id where v.organization_id = #{organization_id} and v.due_date < current_date and v.type_id = 2 and s.is_closed = false) as wpc
                            using (project_id, id)
                  left join (select v.id, v.project_id, v.created_problem_count from v_work_package_stat as v where v.organization_id = #{organization_id}) as wpx
                            using (project_id, id)
     ) as p
         left join (select v.project_id, sum(ispolneno) as ispolneno, sum(all_work_packages) as all_wps from v_project_ispoln_stat as v group by v.project_id) as pis
                   on p.project_id = pis.project_id
group by p.project_id, ispolneno, all_wps
              SQL
            else
              records_array = ActiveRecord::Base.connection.execute <<-SQL
select p.project_id, count(preds) as preds, count (prosr) as prosr, sum(created_problem_count) as problem, ispolneno, all_wps
from (
         select wps.project_id, wps.created_problem_count, wpp.id as preds, wpc.id as prosr
         from v_work_package_stat as wps
                  left join (select v.id, v.project_id from v_work_package_stat as v left join statuses as s on v.status_id = s.id where v.due_date > current_date and v.type_id = #{meropriyatie.id} and s.is_closed = false) as wpp
                            using (project_id, id)
                  left join (select v.id, v.project_id from v_work_package_stat as v left join statuses as s on v.status_id = s.id where v.due_date < current_date and v.type_id = #{kt.id} and s.is_closed = false) as wpc
                            using (project_id, id)
     ) as p
         left join (select v.project_id, sum(ispolneno) as ispolneno, sum(all_work_packages) as all_wps from v_project_ispoln_stat as v group by v.project_id) as pis
                   on p.project_id = pis.project_id
group by p.project_id, ispolneno, all_wps
              SQL
            end
            @wps = []
            records_array.map do |arr|
              stroka = Hash.new
              stroka['_type'] = 'Project'
              stroka['project_id'] = arr['project_id']
              project = Project.find(arr['project_id'])
              stroka['name'] = project.name
              stroka['identifier'] = project.identifier
              stroka['national_id'] = project.national_project_id || 0;
              stroka['kurator'] = project.curator['fio']
              stroka['kurator_id'] = project.curator['id']
              stroka['rukovoditel'] = project.rukovoditel['fio']
              stroka['rukovoditel_id'] = project.rukovoditel['id']
              stroka['budget_fraction'] = project.get_budget_fraction
              stroka['dueDate'] = project.due_date
              stroka['preds'] = arr['preds']
              stroka['prosr'] = arr['prosr']
              stroka['problem'] = arr['problem'] || 0;
              stroka['ispolneno'] = arr['ispolneno']
              stroka['all_wps'] = arr['all_wps']
              @wps << stroka
            end
            @wps
          end
        end
      end
    end
  end
end
