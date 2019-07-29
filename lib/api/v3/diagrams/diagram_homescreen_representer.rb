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
                   when 'budjet' then desktop_budjet_data
                   else [0,0,0,0]
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
          ispolneno = 0 # Порядок важен
          ne_ispolneno = 0
          v_rabote = 0
          riski = 0
          WorkPackage
            .where(type_id: 2, plan_type: :execution)
            .map { |f| [f.status.is_closed, f.due_date] }
            .each do |wp|
            # TODO: Доделать как разбить WP по группам согласно ТЗ
            if wp[0] = true
              ispolneno += 1
            elsif wp[1] > Time.zone.now.beginning_of_day
              v_rabote += 1
            else
              ne_ispolneno += 1
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
        def desktop_budjet_data
          ispolneno = 0 # Порядок важен
          ne_ispolneno = 0
          ostatok = 0
          # TODO: Написать функцию выбоки исполнения бюджета исходя из бюджета мероприятий - нет четкого ТЗ
          result = []
          # Порядок важен
          result << ispolneno
          result << ne_ispolneno
          result << ostatok
        end
      end
    end
  end
end
