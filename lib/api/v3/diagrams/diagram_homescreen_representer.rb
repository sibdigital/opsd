#-- encoding: UTF-8

# This file written by BBM
# 16/07/2019

module API
  module V3
    module Diagrams
      class DiagramHomescreenRepresenter < ::API::Decorators::Single
        def initialize(name: {}, params:, current_user:)
          @name = name
          @performance = params['performance']
        end

        property :data,
                 exec_context: :decorator,
                 getter: ->(*) {
                   case @name
                   when 'pokazateli' then desktop_pokazateli_data
                   when 'kt' then desktop_kt_data
                   when 'budget' then desktop_budget_data
                   when 'riski' then desktop_riski_data
                   when 'zdravoohranenie' then indicator_zdravoohranenie_data
                   when 'obrazovanie' then indicator_obrazovanie_data
                   when 'proizvoditelnost_truda' then indicator_proizvoditelnost_truda_data
                   when 'fed_budget' then fed_budget_data
                   when 'reg_budget' then reg_budget_data
                   when 'other_budget' then other_budget_data
                   when 'head_performance' then head_performance_data
                   else [0, 0, 0, 0]
                   end
                 },
                 render_nil: true

        property :label,
                 exec_context: :decorator,
                 getter: ->(*) {
                   case @name
                   when 'head_performance' then head_performance_label
                   else 'false1'
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
          @plan_facts = PlanFactYearlyTargetValue.find_by_sql <<-SQL
select yearly.project_id, yearly.target_id, sum(final_fact_year_value)as final_fact_year_value, sum(quarterly.target_year_value) as target_plan_year_value
from v_plan_fact_quarterly_target_values as quarterly
left join v_plan_fact_yearly_target_values as yearly
on yearly.project_id = quarterly.project_id and yearly.target_id = quarterly.target_id and yearly.year = quarterly.year
where yearly.year = date_part('year', current_date)
group by yearly.project_id, yearly.target_id
          SQL
          @plan_facts.map do |plan|
            chislitel = plan.final_fact_year_value || 0;
            znamenatel = plan.target_plan_year_value;
            procent = znamenatel == 0 ? 0 : chislitel / znamenatel
            ne_ispolneno += 1 if procent == 0
            v_rabote += 1 if procent < 100
            ispolneno += 1 if procent == 100
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
          ProjectIspolnStat.where(type_id: kt.id).map do |ispoln|
            ispolneno += ispoln.ispolneno
            v_rabote += ispoln.v_rabote
            ne_ispolneno += ispoln.ne_ispolneno
            riski += ispoln.est_riski
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
          cost_objects = CostObject.all
          total_budget = BigDecimal("0")
          spent = BigDecimal("0")

          cost_objects.each do |cost_object|
            total_budget += cost_object.budget
            spent += cost_object.spent
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
          @risks = ProjectRiskOnWorkPackagesStat.find_by_sql <<-SQL
select type, importance_id, sum(count) as count from v_project_risk_on_work_packages_stat
where type in ('created_risk', 'no_risk_problem')
group by type, importance_id
          SQL
          @risks.map do |risk|
            net_riskov += risk.count if risk.type=='no_risk_problem'
            neznachit += risk.count if risk.type=='created_risk' and risk.importance_id = status_neznachit
            kritich += risk.count if risk.type=='created_risk' and risk.importance_id = status_kritich
          end
          result = []
          # Порядок важен
          result << net_riskov
          result << neznachit
          result << kritich
        end

        # Функция заполнения значений долей диаграммы Бюджет на рабочем столе
        def fed_budget_data
          cost_objects = CostObject.all
          total_budget = BigDecimal("0")
          spent = BigDecimal("0")

          cost_objects.each do |cost_object|
            total_budget += cost_object.budget
            spent += cost_object.spent
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

        def reg_budget_data
          cost_objects = CostObject.all
          total_budget = BigDecimal("0")
          labor_budget = BigDecimal("0")
          spent = BigDecimal("0")

          cost_objects.each do |cost_object|
            total_budget += cost_object.budget
            labor_budget += cost_object.labor_budget
            spent += cost_object.spent
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

        def other_budget_data
          cost_objects = CostObject.all
          total_budget = BigDecimal("0")
          material_budget = BigDecimal("0")
          spent = BigDecimal("0")

          cost_objects.each do |cost_object|
            total_budget += cost_object.budget
            material_budget += cost_object.labor_budget
            spent += cost_object.spent
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

        def indicator_zdravoohranenie_data
          [0, 0, 0, 0]
        end

        def indicator_obrazovanie_data
          [0, 0, 0, 0]
        end

        def indicator_proizvoditelnost_truda_data
          [0, 0, 0, 0]
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
