#-- encoding: UTF-8

# This file written by BBM
# 16/07/2019

module API
  module V3
    module Diagrams
      class DiagramHomescreenRepresenter < ::API::Decorators::Single
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

        property :data,
                 exec_context: :decorator,
                 getter: ->(*) {
                   available_user_projects = user_projects(current_user)
                   case @name
                   when 'pokazateli' then
                     desktop_pokazateli_data(available_user_projects)
                   when 'kt' then
                     desktop_kt_data(available_user_projects)
                   when 'budget' then
                     desktop_budget_data(available_user_projects)
                   when 'riski' then
                     desktop_riski_data(available_user_projects)
                   when 'zdravoohranenie' then
                     indicator_data(I18n.t(:national_project_zdravoohr), available_user_projects)
                   when 'obrazovanie' then
                     indicator_data(I18n.t(:national_project_obraz), available_user_projects)
                   when 'demografia' then
                     indicator_data(I18n.t(:national_project_demogr), available_user_projects)
                   when 'cultura' then
                     indicator_data(I18n.t(:national_project_cultur), available_user_projects)
                   when 'avtodorogi' then
                     indicator_data(I18n.t(:national_project_avtodor), available_user_projects)
                   when 'gorsreda' then
                     indicator_data(I18n.t(:national_project_gorsreda), available_user_projects)
                   when 'ekologia' then
                     indicator_data(I18n.t(:national_project_ekol), available_user_projects)
                   when 'nauka' then
                     indicator_data(I18n.t(:national_project_nauka), available_user_projects)
                   when 'msp' then
                     indicator_data(I18n.t(:national_project_msp), available_user_projects)
                   when 'digital' then
                     indicator_data(I18n.t(:national_project_digital), available_user_projects)
                   when 'trud' then
                     indicator_data(I18n.t(:national_project_trud), available_user_projects)
                   when 'export' then
                     indicator_data(I18n.t(:national_project_export), available_user_projects)
                   when 'republic' then
                     indicator_data(I18n.t(:project_republic), available_user_projects)
                   when 'fed_budget' then
                     fed_budget_data
                   when 'reg_budget' then
                     reg_budget_data
                   when 'other_budget' then
                     other_budget_data
                   when 'head_performance' then
                     head_performance_data
                   else
                     [0, 0, 0, 0]
                   end
                 },
                 render_nil: true

        property :label,
                 exec_context: :decorator,
                 getter: ->(*) {
                   case @name
                   when 'head_performance' then
                     head_performance_label
                   when 'zdravoohranenie' then
                     indicator_label
                   when 'obrazovanie' then
                     indicator_label
                   when 'demografia' then
                     indicator_label
                   when 'cultura' then
                     indicator_label
                   when 'avtodorogi' then
                     indicator_label
                   when 'gorsreda' then
                     indicator_label
                   when 'ekologia' then
                     indicator_label
                   when 'nauka' then
                     indicator_label
                   when 'msp' then
                     indicator_label
                   when 'digital' then
                     indicator_label
                   when 'trud' then
                     indicator_label
                   when 'export' then
                     indicator_label
                   when 'republic' then
                     indicator_label
                   else
                     'false1'
                   end
                 },
                 render_nil: true

        def _type
          'DiagramHomescreen'
        end

        private

        #tan
        def user_projects(user)
          user.visible_projects.to_a # пересечение видимых и тех, в которых состоит
        end

        def np_user_projects(user, np)
          np_proj_arr = Project.all.where(national_project_id: np).to_a
          user_proj = user_projects(user)
          np_proj_arr & user_proj
        end

        def sql_text_desktop_pokazateli_data
          #+-tan 2019.10.16
          # проведен рефакторинг фильтрация проектов по видимости пользователю проводится непосредственно в запросе
          # это рациональнее и позволяет избежать ошибок связанных с проверкой видимости шаблонов
          sql_query = <<-SQL
            select yearly.project_id, yearly.target_id, 
            sum(final_fact_year_value)as final_fact_year_value, sum(quarterly.target_year_value) as target_plan_year_value
            from v_plan_fact_quarterly_target_values as quarterly
            left join v_plan_fact_yearly_target_values as yearly
            on yearly.project_id = quarterly.project_id and yearly.target_id = quarterly.target_id and yearly.year = quarterly.year
            where yearly.year = date_part('year', current_date) and yearly.project_id in (?)
            group by yearly.project_id, yearly.target_id
          SQL
          sql_query
        end
        # bbm(
        # Функция заполнения значений долей диаграммы Показатели на рабочем столе
        def desktop_pokazateli_data(available_user_projects)
          max = 1
          average = 0.9
          net_otkloneniy = 0
          small_otkloneniya = 0
          big_otkloneniya = 0

          user_proj = @project && @project != '0' ? [@project] : available_user_projects.map(&:id)
          targets = Target.where("type_id != ?", TargetType.where(name: I18n.t('targets.target')).first.id)
                         .where("project_id in (#{user_proj.join(",")})")
          count_targets = targets.count

          targets = targets.where("exists(select id from target_execution_values where target_id = targets.id)")
                      .where("exists(select id from work_package_targets where target_id = targets.id)")
          slice_plan_now = FirstPlanTarget.get_now(user_proj.join(","))
          slice_fact_now = LastFactTarget.get_now(user_proj.join(","))
          targets.each do |t|
            target_plan_now = slice_plan_now.find {|slice| slice["target_id"] == t.id}
            target_fact_now = slice_fact_now.select {|slice| slice["target_id"] == t.id}
            target_plan_now = target_plan_now.nil? ? 0.0 : target_plan_now["value"].nil? ? 0.0 : target_plan_now["value"].to_f
            target_fact_now = target_fact_now.sum { |f| f["value"].nil? ? 0 : f["value"].to_f }
            if target_plan_now <= target_fact_now
              net_otkloneniy += 1
            elsif target_plan_now * average <= target_fact_now
              small_otkloneniya += 1
            else
              big_otkloneniya += 1
            end
          end
          net_dannyh = count_targets - (net_otkloneniy + small_otkloneniya + big_otkloneniya)
          result = [net_otkloneniy, small_otkloneniya, big_otkloneniya, net_dannyh]
          result
        end

        # Функция заполнения значений долей диаграммы KT на рабочем столе
        def desktop_kt_data(available_user_projects)
          ispolneno = 0
          v_rabote = 0
          ne_ispolneno = 0
          riski = 0

          @kontrol_point_type = Type.find_by name: I18n.t(:default_type_milestone) || @kontrol_point_type
          user_proj = @project && @project != '0' ? @project : available_user_projects.map(&:id)
          pis = ProjectIspolnStat.where(type_id: @kontrol_point_type.id)
          pis = pis.where(project_id: user_proj)

          pis.map do |ispoln|
            ispolneno += ispoln.ispolneno
            v_rabote += ispoln.v_rabote
            ne_ispolneno += ispoln.ne_ispolneno
            riski += ispoln.est_riski
          end
          # Порядок важен
          result = [ispolneno, ne_ispolneno, v_rabote, riski]
          result
        end

        # Функция заполнения значений долей диаграммы Бюджет на рабочем столе
        def desktop_budget_data(available_user_projects)
          cost_objects = CostObject.by_user @current_user
          total_budget = BigDecimal("0")
          spent = BigDecimal("0")

          user_proj = @project && @project != '0' ? Project.where(id: @project) : available_user_projects

          cost_objects.each do |cost_object|
            user_proj.each do |uproj|
              if uproj.id == cost_object.project_id
                total_budget += cost_object.budget
                spent += cost_object.spent
              end#можно стереть
            end
          end

          # Порядок важен
          risk_ispoln = 0
          ostatok = total_budget - spent
          result = [spent, risk_ispoln, ostatok]
          result
        end

        def sql_text_desktop_riski_data
          sql_query = <<-SQL
            select type, project_id, importance_id, sum(count) as count
            from v_project_risk_on_work_packages_stat
            where type in ('created_risk', 'created_problem','no_risk_problem') and project_id in (?)
            group by type, project_id, importance_id
          SQL
          sql_query
        end

        def desktop_riski_data(available_user_projects)
          net_riskov = 0
          neznachit = 0
          kritich = 0
          @status_neznachit = Importance.find_by(name: I18n.t(:default_impotance_low)) || @status_neznachit
          @status_kritich = Importance.find_by(name: I18n.t(:default_impotance_critical)) || @status_kritich

          user_proj = @project && @project != '0' ? @project : available_user_projects.map(&:id)
          @risks = ProjectRiskOnWorkPackagesStat.find_by_sql([sql_text_desktop_riski_data(), user_proj])

          @risks.map do |risk|
            if risk.type == 'no_risk_problem'
              net_riskov += risk.count
            end
            if (risk.type == 'created_risk' and (risk.importance_id == @status_neznachit.id or risk.importance_id == nil)) or (risk.type == 'created_problem')
              neznachit += risk.count
            end
            if risk.type == 'created_risk' and risk.importance_id == @status_kritich.id
              kritich += risk.count
            end
          end
          result = [neznachit, kritich]
          result
          # Порядок важен
          # fva: Раскомментировать если необходимо будет вернуть графу: отсутствует.
          # Также не забудьте раскомментировать строку в файле desktop-tab.html
          #result << net_riskov
        end


        # Функция заполнения значений долей диаграммы Бюджет на рабочем столе
        def fed_budget_data

          data = AllBudgetsHelper.federal_budget current_user

          result = [data[:spent], data[:risk_ispoln], data[:ostatok]]
          result

        end

        def reg_budget_data
          data = AllBudgetsHelper.regional_budget current_user

          result = [data[:spent], data[:risk_ispoln], data[:ostatok]]
          result

        end

        def other_budget_data
          data = AllBudgetsHelper.vnebudget_budget current_user
          # Порядок важен
          result = [data[:spent], data[:risk_ispoln], data[:ostatok]]
          result

        end

        def indicator_label
          if @indikator_data and @indikator_data == [0, 0, 0, 0]
            'hidden'
          else
            'visible'
          end
        end

        def indicator_data(name, available_user_projects)
          max = 1
          average = 0.9
          net_otkloneniy = 0
          small_otkloneniya = 0
          big_otkloneniya = 0
          net_dannyh = 0
          nat_proj = NationalProject.find_by(name: name)
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
          @indikator_data = [net_otkloneniy, small_otkloneniya, big_otkloneniya, net_dannyh]
        end

        def head_performance_label
          if @performance
            head_performance = HeadPerformanceIndicator.find(@performance)
            head_performance.name
          else
            ''
          end
        end

        def head_performance_data
          if @performance
            head_performance = HeadPerformanceIndicator.find(@performance)
            quarter1 = head_performance.head_performance_indicator_values
                         .where("year = date_part('year', CURRENT_DATE)")
                         .where(quarter: 1).last
            value1 = quarter1 ? quarter1.value : 0
            quarter2 = head_performance.head_performance_indicator_values
                         .where("year = date_part('year', CURRENT_DATE)")
                         .where(quarter: 2).last
            value2 = quarter2 ? quarter2.value : 0
            quarter3 = head_performance.head_performance_indicator_values
                         .where("year = date_part('year', CURRENT_DATE)")
                         .where(quarter: 3).last
            value3 = quarter3 ? quarter3.value : 0
            quarter4 = head_performance.head_performance_indicator_values
                         .where("year = date_part('year', CURRENT_DATE)")
                         .where(quarter: 4).last
            value4 = quarter4 ? quarter4.value : 0
            [value1, value2, value3, value4]
          else
            [0, 0, 0, 0]
          end
        end
      end
    end
  end
end
