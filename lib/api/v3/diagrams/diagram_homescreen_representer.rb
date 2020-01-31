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
        end

        property :data,
                 exec_context: :decorator,
                 getter: ->(*) {
                   case @name
                   when 'pokazateli' then
                     desktop_pokazateli_data
                   when 'kt' then
                     desktop_kt_data
                   when 'budget' then
                     desktop_budget_data
                   when 'riski' then
                     desktop_riski_data
                   when 'zdravoohranenie' then
                     indicator_data(I18n.t(:national_project_zdravoohr))
                   when 'obrazovanie' then
                     indicator_data(I18n.t(:national_project_obraz))
                   when 'demografia' then
                     indicator_data(I18n.t(:national_project_demogr))
                   when 'cultura' then
                     indicator_data(I18n.t(:national_project_cultur))
                   when 'avtodorogi' then
                     indicator_data(I18n.t(:national_project_avtodor))
                   when 'gorsreda' then
                     indicator_data(I18n.t(:national_project_gorsreda))
                   when 'ekologia' then
                     indicator_data(I18n.t(:national_project_ekol))
                   when 'nauka' then
                     indicator_data(I18n.t(:national_project_nauka))
                   when 'msp' then
                     indicator_data(I18n.t(:national_project_msp))
                   when 'digital' then
                     indicator_data(I18n.t(:national_project_digital))
                   when 'trud' then
                     indicator_data(I18n.t(:national_project_trud))
                   when 'export' then
                     indicator_data(I18n.t(:national_project_export))
                   when 'republic' then
                     indicator_data(nil)
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

        # bbm(
        # Функция заполнения значений долей диаграммы Показатели на рабочем столе
        def desktop_pokazateli_data
          ispolneno = 0 # Порядок важен
          ne_ispolneno = 0
          v_rabote = 0
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
          arr = @project && @project != '0' ? @project : Project.visible(current_user).map(&:id)
          @plan_facts = PlanFactYearlyTargetValue.find_by_sql([sql_query, arr])
          @plan_facts.map do |plan|
            project = plan.project
            exist = which_role(project, @current_user, @global_role)
            if exist
              chislitel = plan.final_fact_year_value || 0
              znamenatel = plan.target_plan_year_value || 0
              procent = znamenatel == 0 ? 0 : (chislitel / znamenatel * 100)
              ne_ispolneno += 1 if procent == 0
              v_rabote += 1 if procent < 100 and procent > 0
              ispolneno += 1 if procent == 100
            end
          end
          result = []
          # Порядок важен
          result << ispolneno
          result << ne_ispolneno
          result << v_rabote
        end

        # Функция заполнения значений долей диаграммы KT на рабочем столе
        def desktop_kt_data
          ispolneno = 0
          v_rabote = 0
          ne_ispolneno = 0
          riski = 0
          kt = Type.find_by name: I18n.t(:default_type_milestone)
          pis = ProjectIspolnStat.where(type_id: kt.id)
          pis = pis.where(project_id: @project) if @project && @project != '0'
          pis.map do |ispoln|
            # +-tan 2019.09.17
            if ispoln.project.visible? current_user
              project = ispoln.project #Project.visible(current_user).find(ispoln.project_id)
              exist = which_role(project, @current_user, @global_role)
              if exist
                ispolneno += ispoln.ispolneno
                v_rabote += ispoln.v_rabote
                ne_ispolneno += ispoln.ne_ispolneno
                riski += ispoln.est_riski
              end
            end
          end
          result = []
          # Порядок важен
          result << ispolneno
          result << ne_ispolneno
          result << v_rabote
          result << riski
        end

        # Функция заполнения значений долей диаграммы Бюджет на рабочем столе
        def desktop_budget_data
          cost_objects = CostObject.by_user @current_user
          total_budget = BigDecimal("0")
          spent = BigDecimal("0")

          cost_objects.each do |cost_object|
            if @project && @project != '0'
              if @project == cost_object.project_id.to_s
                total_budget += cost_object.budget
                spent += cost_object.spent
              end
            else
              project = Project.visible(current_user).find(cost_object.project_id)
              exist = which_role(project, @current_user, @global_role)
              if exist
                total_budget += cost_object.budget
                spent += cost_object.spent
              end
            end
          end

          spent
          risk_ispoln = 0
          ostatok = total_budget - spent
          result = []
          # Порядок важен
          result << spent
          result << risk_ispoln
          result << ostatok
        end

        def desktop_riski_data
          net_riskov = 0
          neznachit = 0
          kritich = 0
          status_neznachit = Importance.find_by(name: I18n.t(:default_impotance_low))
          status_kritich = Importance.find_by(name: I18n.t(:default_impotance_critical))
          sql_query = <<-SQL
            select type, project_id, importance_id, sum(count) as count
            from v_project_risk_on_work_packages_stat
            where type in ('created_risk', 'created_problem','no_risk_problem') and project_id in (?)
            group by type, project_id, importance_id
          SQL
          arr = @project && @project != '0' ? @project : Project.visible(current_user).map(&:id)
          @risks = ProjectRiskOnWorkPackagesStat.find_by_sql([sql_query, arr])
          @risks.map do |risk|
            # +-tan 2019.09.17
            if risk.project.visible? current_user
              project = risk.project #Project.visible(current_user).find(risk.project_id)
              exist = which_role(project, @current_user, @global_role)
              if exist
                net_riskov += risk.count if risk.type == 'no_risk_problem'
                neznachit += risk.count if (risk.type == 'created_risk' and risk.importance_id == status_neznachit.id) or (risk.type == 'created_problem')
                kritich += risk.count if risk.type == 'created_risk' and risk.importance_id == status_kritich.id
              end
            end
          end
          result = []
          # Порядок важен
          result << net_riskov
          result << neznachit
          result << kritich
        end

        # Функция заполнения значений долей диаграммы Бюджет на рабочем столе
        def fed_budget_data
          # cost_objects = CostObject.by_user @current_user
          # total_budget = BigDecimal("0")
          # spent = BigDecimal("0")
          #
          # cost_objects.each do |cost_object|
          #   total_budget += cost_object.budget
          #   spent += cost_object.spent
          # end

          # total_budget: total_budget,
          #   labor_budget: labor_budget,
          #   material_budget: material_budget,
          #   spent: spent, #израсходовано
          #   ostatok: total_budget - spent,
          #   ne_ispoln: 0,
          #   risk_ispoln: 0
          data = AllBudgetsHelper.federal_budget current_user

          #spent
          #risk_ispoln = 0
          # ostatok = total_budget - spent
          result = []
          # Порядок важен
          result << data[:spent]
          result << data[:risk_ispoln]
          result << data[:ostatok]
        end

        def reg_budget_data
          data = AllBudgetsHelper.regional_budget current_user
          result = []
          # Порядок важен
          result << data[:spent]
          result << data[:risk_ispoln]
          result << data[:ostatok]
          # cost_objects = CostObject.by_user @current_user
          # total_budget = BigDecimal("0")
          # labor_budget = BigDecimal("0")
          # spent = BigDecimal("0")
          #
          # cost_objects.each do |cost_object|
          #   total_budget += cost_object.budget
          #   labor_budget += cost_object.labor_budget
          #   spent += cost_object.spent
          # end
          #
          # spent
          # risk_ispoln = 0
          # ostatok = total_budget - spent
          # result = []
          # # Порядок важен
          # result << spent
          # result << risk_ispoln
          # result << ostatok
        end

        def other_budget_data
          data = AllBudgetsHelper.vnebudget_budget current_user
          result = []
          # Порядок важен
          result << data[:spent]
          result << data[:risk_ispoln]
          result << data[:ostatok]

          # cost_objects = CostObject.by_user @current_user
          # total_budget = BigDecimal("0")
          # material_budget = BigDecimal("0")
          # spent = BigDecimal("0")
          #
          # cost_objects.each do |cost_object|
          #   total_budget += cost_object.budget
          #   material_budget += cost_object.labor_budget
          #   spent += cost_object.spent
          # end
          #
          # spent
          # risk_ispoln = 0
          # ostatok = total_budget - spent
          # result = []
          # # Порядок важен
          # result << spent
          # result << risk_ispoln
          # result << ostatok
        end

        def indicator_label
          if @indikator_data and @indikator_data == [0, 0, 0, 0]
            'hidden'
          else
            'visible'
          end
        end

        def indicator_data(name)
          max = 1
          overage = 0.8
          projects = [0]
          net_otkloneniy = 0
          small_otkloneniya = 0
          big_otkloneniya = 0
          net_dannyh = 0
          Project.all.each do |project|
            exist = which_role(project, @current_user, @global_role)
            if exist
              projects << project.id
            end
          end
          nat_proj = NationalProject.find_by(name: name)
          pfqtv = PlanFactQuarterlyTargetValue.where("year = date_part('year', CURRENT_DATE) and project_id in (" + projects.join(",") + ")")
          pfqtv = if name
                    pfqtv.where(national_project_id: nat_proj.id)
                  else
                    pfqtv.where("national_project_id is null")
                  end
          quarter = ((Time.now.month - 1) / 3) + 1
          pfqtv.group_by(&:target_id).each do |target, arr|
            fact_value = 0
            target_value = 0
            total = 0
            arr.each do |row|
              case quarter
              when 1
                f = row.fact_quarter1_value
                t = row.target_quarter1_value
                p = row.plan_quarter1_value
              when 2
                f = row.fact_quarter2_value
                t = row.target_quarter2_value
                p = row.plan_quarter2_value
              when 3
                f = row.fact_quarter3_value
                t = row.target_quarter3_value
                p = row.plan_quarter3_value
              when 4
                f = row.fact_quarter4_value
                t = row.target_quarter4_value
                p = row.plan_quarter4_value
              end

              if f
                if t
                  fact_value = f
                  target_value = t
                  total += 1
                elsif row.target_year_value
                  fact_value = f
                  target_value = row.target_year_value
                  total += 1
                else
                  net_dannyh += 1
                end
              else
                if p
                  if t
                    fact_value = 0
                    target_value = t
                    total += 1
                  elsif row.target_year_value
                    fact_value = 0
                    target_value = row.target_year_value
                    total += 1
                  else
                    net_dannyh += 1
                  end
                else
                  net_dannyh += 1
                end
              end

=begin
              if f
                if t
                  fact_value += f
                  target_value += t
                  total += 1
                elsif row.target_year_value
                  fact_value += f
                  target_value += row.target_year_value
                  total += 1
                else
                  net_dannyh += 1
                end
              else
                net_dannyh += 1
              end
=end
            end
            drob = target_value == 0 ? 0 : fact_value / target_value
            if drob >= max
              net_otkloneniy += total
            end
            if drob >= overage and drob < max
              small_otkloneniya += total
            end
            if drob < overage
              big_otkloneniya += total
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
