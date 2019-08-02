#-- encoding: UTF-8

# This file written by BBM
# 16/07/2019

module API
  module V3
    module Diagrams
      class DiagramHomescreenRepresenter < ::API::Decorators::Single
        def initialize(name: {}, current_user:)
          @name = name
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
                   else [0, 0, 0, 0]
                   end
                 },
                 render_nil: true

        property :label,
                 exec_context: :decorator,
                 getter: ->(*) {
                   'false1'
                 },
                 render_nil: true

        def _type
          'DiagramHomescreen'
        end

        private

        # bbm(
        # Функция заполнения значений долей диаграммы Показатели на рабочем столе
        # В случае имзенения алгоритма среднего процента исполнения переделать функцию completed_percent_sd в project.rb
        def desktop_pokazateli_data
          ispolneno = 0 # Порядок важен
          ne_ispolneno = 0
          v_rabote = 0
          Project.all.map(&:completed_percent_sd).each do |completed_percent|
            case completed_percent
            when 0
              ne_ispolneno += 1
            when 100
              ispolneno += 1
            else
              v_rabote += 1
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
          status_isp = Status.find_by(name: I18n.t(:default_status_completed))
          WorkPackage # С закрытыми рисками
            .joins(:type)
            .joins(:work_package_problems)
            .where("status_id = ?", status_isp.id)
            .where(types: { name: I18n.t(:default_type_milestone) },
                   plan_type: :execution, result_agreed: true, done_ratio: 100)
            .select(:id, "min(work_package_problems.status)")
            .group(:id)
            .map do |wp|
            if wp.min == 'solved'
              ispolneno += 1
            end
          end
          WorkPackage # То же самое но вообще без рисков
            .joins(:type)
            .where("status_id = ?", status_isp.id)
            .where(types: { name: I18n.t(:default_type_milestone) },
                   plan_type: :execution, result_agreed: true, done_ratio: 100)
            .map do |wp|
            if wp.work_package_problems.empty?
              ispolneno += 1
            end
          end
          status_vrab = Status.find_by(name: I18n.t(:default_status_in_work))
          WorkPackage
            .joins(:type)
            .joins(:work_package_problems)
            .where("status_id = ? and due_date > NOW()", status_vrab.id)
            .where(types: { name: I18n.t(:default_type_milestone) }, plan_type: :execution)
            .select(:id, "min(work_package_problems.status)")
            .group(:id)
            .map do |wp|
            if wp.min == 'solved'
              v_rabote += 1
            end
          end
          WorkPackage
            .joins(:type)
            .where("status_id = ? and due_date > NOW()", status_vrab.id)
            .where(types: { name: I18n.t(:default_type_milestone) }, plan_type: :execution)
            .map do |wp|
            if wp.work_package_problems.empty?
              v_rabote += 1
            end
          end
          status_otm = Status.find_by(name: I18n.t(:default_status_cancelled))
          WorkPackage
            .joins(:type)
            .where("due_date < NOW()", status_vrab.id)
            .where(types: { name: I18n.t(:default_type_milestone) }, plan_type: :execution)
            .map do |wp|
            if wp.done_ratio != 100 or (wp.status.name != status_otm.name and wp.status.name != status_isp.name)
              ne_ispolneno += 1
            end
          end
          WorkPackage
            .joins(:type)
            .joins(:work_package_problems)
            .where("status_id not in (?, ?) and due_date > NOW()", status_otm.id, status_isp.id)
            .where(types: { name: I18n.t(:default_type_milestone) }, plan_type: :execution)
            .select(:id, "min(work_package_problems.status)")
            .group(:id)
            .map do |wp|
            riski += 1
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
          status_neznachit = Importance.find_by(name: I18n.t(:default_impotance_low))
          status_kritich = Importance.find_by(name: I18n.t(:default_impotance_critical))
          neznachit = WorkPackageProblem
                        .joins(:risk)
                        .where(risks: { importance_id: status_neznachit.id })
                        .count
          kritich = WorkPackageProblem
                      .joins(:risk)
                      .where(risks: { importance_id: status_kritich.id })
                      .count
          result = []
          # Порядок важен
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
      end
    end
  end
end
