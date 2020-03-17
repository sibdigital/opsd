module API
  module V3
    module Diagrams
      class DiagramMunicipalityRepresenter < ::API::Decorators::Single
        include ::API::V3::Utilities::RoleHelper

        def initialize(params:, current_user:, global_role:)
          @name = params[:name]
          @performance = params[:performance]
          @organization = params[:organization]
          @current_user = current_user
          @global_role = global_role
          @project = params[:project]
          @raionId = params[:raionId]
        end

        property :national_projects,
                 exec_context: :decorator,
                 getter: ->(*) {
                   visible_nps = NationalProject.visible_national_projects(current_user)
                   result = []
                   visible_nps.each do |np|
                     name = np.name
                     data = indicator_data(np)
                     label = 'false1'
                     if data.inject(0){|sum,x| sum + x } != 0 #Не добавляем если все по нулям
                       result << {name: name, data: data, label: label}
                     end
                   end
                   result
                 }

        def _type
          'DiagramMunicipality'
        end

        def np_user_projects(user, np)
          np_proj_arr = Project.all.where(national_project_id: np).to_a
          user_proj = user.visible_projects.to_a
          np_proj_arr & user_proj
        end

        def indicator_data(nat_proj)
          max = 1
          average = 0.9
          net_otkloneniy = 0
          small_otkloneniya = 0
          big_otkloneniya = 0
          net_dannyh = 0
          projects = np_user_projects(current_user, nat_proj.id).map(&:id)
          if @raionId && @raionId != '0'
            projects = Raion.projects_by_id(@raionId, projects).map {|p| p.id}
          end
          projects = projects.empty? ? [0] : projects
          targets = Target.where("type_id != ?", TargetType.where(name: I18n.t('targets.target')).first.id)
                        .where("project_id in (#{projects.join(",")})")
          slice_plan_now = FirstPlanTarget.get_now(projects.join(","))
          slice_fact_now = LastFactTarget.get_now(projects.join(","))
          targets.each do |t|
            target_plan_now = slice_plan_now.find {|slice| slice["target_id"] == t.id}
            target_fact_now = slice_fact_now.select {|slice| slice["target_id"] == t.id}
            target_plan_now = target_plan_now.nil? ? 0.0 : target_plan_now["value"].nil? ? 0.0 : target_plan_now["value"].to_f
            target_fact_now = target_fact_now.sum { |f| f["value"].nil? ? 0 : f["value"].to_f }
            if !t.target_execution_values.count.zero? and !t.work_package_targets.count.zero?
              if target_plan_now <= target_fact_now
                net_otkloneniy += 1
              elsif target_plan_now * average <= target_fact_now
                small_otkloneniya += 1
              else
                big_otkloneniya += 1
              end
            else
              net_dannyh += 1
            end
          end
          [net_otkloneniy, small_otkloneniya, big_otkloneniya, net_dannyh]
        end
      end
    end
  end
end

