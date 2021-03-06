#-- encoding: UTF-8
# This file written by BAN
# 08/07/2019

module BasicData
  class KeyPerformanceIndicatorSeeder < Seeder
    def seed_data!

      KpiCalcMethod.transaction do
        kpi_method_data.each do |attributes|
          KpiCalcMethod.create!(attributes)
        end
      end

      KpiObject.transaction do
        kpi_objects_data.each do |attributes|
          KpiObject.create!(attributes)
        end
      end

      KeyPerformanceIndicator.transaction do
        data.each do |attributes|
          KeyPerformanceIndicator.create!(attributes)
        end
      end

      KeyPerformanceIndicatorCase.transaction do
        cases_data.each do |attributes|
          KeyPerformanceIndicatorCase.create!(convert(attributes))
        end
      end

    end

    def applicable?
      KeyPerformanceIndicator.all.empty?
    end

    def not_applicable_message
      'Skipping KPI as there are already some configured'
    end

    def kpi_by_name(name)
      np = KeyPerformanceIndicator.find_by(name: name)
      if np != nil
        np.id
      end
    end

    def role_by_name(name)
      np = Role.find_by(name: name)
      if np != nil
        np.id
      end
    end

    def kpi_method_by_name(name)
      np = KpiCalcMethod.find_by(name: name)
      if np != nil
        np.id
      end
    end

    def kpi_objects_by_name(name)
      np = KpiObject.find_by(name: name)
      if np != nil
        np.id
      end
    end

    def kpi_method_data
      [
        { name: I18n.t(:default_kpi_method_olap), position: 1, is_default: false, type: "KpiCalcMethod", active: true },
        { name: I18n.t(:default_kpi_method_count), position: 2, is_default: false, type: "KpiCalcMethod", active: true },
        { name: I18n.t(:default_kpi_method_hand), position: 3, is_default: false, type: "KpiCalcMethod", active: true },
      ]
    end

    def kpi_objects_data
      [
        { name: I18n.t(:default_kpi_object_project), position: 1, is_default: false, type: "KpiObject", active: true },
        { name: I18n.t(:default_kpi_object_work_package), position: 2, is_default: false, type: "KpiObject", active: true },
        { name: I18n.t(:default_kpi_object_risk), position: 3, is_default: false, type: "KpiObject", active: true },
        { name: I18n.t(:default_kpi_object_meeting), position: 3, is_default: false, type: "KpiObject", active: true },
      ]
    end

    def data
      [
        { name: I18n.t(:default_kpi_count_opened_project), weight: 1, calc_method: "sum", enable: true,
          method_id: kpi_method_by_name(I18n.t(:default_kpi_method_count)), object_id: kpi_objects_by_name(I18n.t(:default_kpi_object_project))},
        { name: I18n.t(:default_kpi_count_support_project), weight: 1, calc_method: "sum", enable: true,
          method_id: kpi_method_by_name(I18n.t(:default_kpi_method_count)), object_id: kpi_objects_by_name(I18n.t(:default_kpi_object_project))},
        { name: I18n.t(:default_kpi_count_opened_meeting), weight: 1, calc_method: "sum", enable: true,
          method_id: kpi_method_by_name(I18n.t(:default_kpi_method_count)), object_id: kpi_objects_by_name(I18n.t(:default_kpi_object_meeting))},
        { name: I18n.t(:default_kpi_no_red_kt), weight: 1, calc_method: "sum", enable: true,
          method_id: kpi_method_by_name(I18n.t(:default_kpi_method_count)), object_id: kpi_objects_by_name(I18n.t(:default_kpi_object_work_package))},
        { name: I18n.t(:default_kpi_monitoring), weight: 1, calc_method: "sum", enable: true,
          method_id: kpi_method_by_name(I18n.t(:default_kpi_method_count)), object_id: kpi_objects_by_name(I18n.t(:default_kpi_object_work_package))},
        { name: I18n.t(:default_kpi_closed_project), weight: 1, calc_method: "sum", enable: true,
          method_id: kpi_method_by_name(I18n.t(:default_kpi_method_count)), object_id: kpi_objects_by_name(I18n.t(:default_kpi_object_project))},
        { name: I18n.t(:default_kpi_saved_risks), weight: 1, calc_method: "sum", enable: true,
          method_id: kpi_method_by_name(I18n.t(:default_kpi_method_hand)), object_id: kpi_objects_by_name(I18n.t(:default_kpi_object_risk))},
        { name: I18n.t(:default_kpi_minimize_risks), weight: 1, calc_method: "sum", enable: true,
          method_id: kpi_method_by_name(I18n.t(:default_kpi_method_count)), object_id: kpi_objects_by_name(I18n.t(:default_kpi_object_risk))},
        { name: I18n.t(:default_kpi_target), weight: 1, calc_method: "sum", enable: true,
          method_id: kpi_method_by_name(I18n.t(:default_kpi_method_olap)), object_id: kpi_objects_by_name(I18n.t(:default_kpi_object_work_package))},
      ]

    end

    def convert(attr)
      {
        percent:  attr[:percent],
        min_value: attr[:min_value],
        max_value: attr[:max_value],
        enable: attr[:enable],
        period: attr[:period],
        key_performance_indicator_id: kpi_by_name(attr[:name]),
        role_id:  role_by_name(attr[:role])
      }
    end

    def cases_data
      I18n.t(:default_status_not_start)
      [
        #1.	Количество открываемых проектов.
        # Учитывать количество проектов за квартал, в которых пользователь имеет одну из следующих ролей:
        # куратор проекта, руководитель проекта, администратор проекта
        # 1.	Количество открываемых проектов:
        # 1-3 проектов в квартал – 10%
        # 3-5 проектов в квартал – 30%
        { name: I18n.t(:default_kpi_count_opened_project), role: I18n.t(:default_role_project_curator), percent: 10, min_value: 1, max_value: 3,enable: true, period: "Quarterly" },
        { name: I18n.t(:default_kpi_count_opened_project), role: I18n.t(:default_role_project_curator), percent: 30, min_value: 4, max_value: 5,enable: true, period: "Quarterly" },

        { name: I18n.t(:default_kpi_count_opened_project), role: I18n.t(:default_role_project_head), percent: 10, min_value: 1, max_value: 3,enable: true, period: "Quarterly" },
        { name: I18n.t(:default_kpi_count_opened_project), role: I18n.t(:default_role_project_head), percent: 30, min_value: 4, max_value: 5,enable: true, period: "Quarterly" },

        { name: I18n.t(:default_kpi_count_opened_project), role: I18n.t(:default_role_project_admin), percent: 10, min_value: 1, max_value: 3,enable: true, period: "Quarterly" },
        { name: I18n.t(:default_kpi_count_opened_project), role: I18n.t(:default_role_project_admin), percent: 30, min_value: 4, max_value: 5,enable: true, period: "Quarterly" },

        #2.	Количество сопровождаемых проектов.
        #Учитывать текущее количество проектов, в которых пользователь имеет оду из следующих ролей:
        # координатор от Проектного офиса, ответственный за блок мероприятий, исполнитель.
        #5-7 проектов – 10%
        #7-10 – 20%
        #10-15 – 40%
        #15-20 – 50%
        { name: I18n.t(:default_kpi_count_support_project), role: I18n.t(:default_role_project_office_coordinator), percent: 10, min_value: 5, max_value: 7,enable: true, period: "" },
        { name: I18n.t(:default_kpi_count_support_project), role: I18n.t(:default_role_project_office_coordinator), percent: 20, min_value: 8, max_value: 10,enable: true, period: "" },
        { name: I18n.t(:default_kpi_count_support_project), role: I18n.t(:default_role_project_office_coordinator), percent: 40, min_value: 11, max_value: 15,enable: true, period: "" },
        { name: I18n.t(:default_kpi_count_support_project), role: I18n.t(:default_role_project_office_coordinator), percent: 50, min_value: 16, max_value: 20,enable: true, period: "" },

        { name: I18n.t(:default_kpi_count_support_project), role: I18n.t(:default_role_events_responsible), percent: 10, min_value: 5, max_value: 7,enable: true, period: "" },
        { name: I18n.t(:default_kpi_count_support_project), role: I18n.t(:default_role_events_responsible), percent: 20, min_value: 8, max_value: 10,enable: true, period: "" },
        { name: I18n.t(:default_kpi_count_support_project), role: I18n.t(:default_role_events_responsible), percent: 40, min_value: 11, max_value: 15,enable: true, period: "" },
        { name: I18n.t(:default_kpi_count_support_project), role: I18n.t(:default_role_events_responsible), percent: 50, min_value: 16, max_value: 20,enable: true, period: "" },

        { name: I18n.t(:default_kpi_count_support_project), role: I18n.t(:default_role_ispolnitel), percent: 10, min_value: 5, max_value: 7,enable: true, period: "" },
        { name: I18n.t(:default_kpi_count_support_project), role: I18n.t(:default_role_ispolnitel), percent: 20, min_value: 8, max_value: 10,enable: true, period: "" },
        { name: I18n.t(:default_kpi_count_support_project), role: I18n.t(:default_role_ispolnitel), percent: 40, min_value: 11, max_value: 15,enable: true, period: "" },
        { name: I18n.t(:default_kpi_count_support_project), role: I18n.t(:default_role_ispolnitel), percent: 50, min_value: 16, max_value: 20,enable: true, period: "" },

        # 3.	Количество организованных совещаний, мероприятий.
        #   Учитывать количество созданных пользователем за квартал совещаний.
        #
        # meetings.author_id
        #
        # 1-10 в квартал – 15%
        # 10 – 20 – 30%
        # 20 и выше – 40%
        { name: I18n.t(:default_kpi_count_opened_meeting), role: nil, percent: 15, min_value: 1, max_value: 10,enable: true, period: "Quarterly" },
        { name: I18n.t(:default_kpi_count_opened_meeting), role: nil, percent: 30, min_value: 11, max_value: 20,enable: true, period: "Quarterly" },
        { name: I18n.t(:default_kpi_count_opened_meeting), role: nil, percent: 40, min_value: 20, max_value: 9999,enable: true, period: "Quarterly" },

        #   4.	Отсутствие красных контрольных точек
        # Учитывать сроки исполнения мероприятий за месяц, квартал и год для
        # Ролей: куратор проекта, руководитель проекта, администратор проекта,
        # координатор от Проектного офиса по проекту в целом, для ролей ответственный за блок мероприятий,
        # исполнитель, по назначенным им мероприятиям.
        #
        # Если статус = незавершен, неотменен и due_date<current_date и month(due_date)=month(current_date)
        # current_date - сделать входным параметром
        #
        # подумать надо
        #
        # 4.	Отсутствие красных контрольных точек
        # в 1 отчетный месяц – 10%
        # в отчетный квартал – 15%
        # в год – 30%
        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_project_curator), percent: 10, min_value: 0, max_value: 0,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_project_curator), percent: 15, min_value: 0, max_value: 0,enable: true, period: "Quarterly" },
        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_project_curator), percent: 30, min_value: 0, max_value: 0,enable: true, period: "Yearly" },

        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_project_head), percent: 10, min_value: 0, max_value: 0,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_project_head), percent: 15, min_value: 0, max_value: 0,enable: true, period: "Quarterly" },
        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_project_head), percent: 30, min_value: 0, max_value: 0,enable: true, period: "Yearly" },

        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_project_admin), percent: 10, min_value: 0, max_value: 0,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_project_admin), percent: 15, min_value: 0, max_value: 0,enable: true, period: "Quarterly" },
        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_project_admin), percent: 30, min_value: 0, max_value: 0,enable: true, period: "Yearly" },

        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_project_office_coordinator), percent: 10, min_value: 0, max_value: 0,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_project_office_coordinator), percent: 15, min_value: 0, max_value: 0,enable: true, period: "Quarterly" },
        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_project_office_coordinator), percent: 30, min_value: 0, max_value: 0,enable: true, period: "Yearly" },

        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_events_responsible), percent: 10, min_value: 0, max_value: 0,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_events_responsible), percent: 15, min_value: 0, max_value: 0,enable: true, period: "Quarterly" },
        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_events_responsible), percent: 30, min_value: 0, max_value: 0,enable: true, period: "Yearly" },

        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_ispolnitel), percent: 10, min_value: 0, max_value: 0,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_ispolnitel), percent: 15, min_value: 0, max_value: 0,enable: true, period: "Quarterly" },
        { name: I18n.t(:default_kpi_no_red_kt), role: I18n.t(:default_role_ispolnitel), percent: 30, min_value: 0, max_value: 0,enable: true, period: "Yearly" },

        #   5.	Осуществление мониторинга региональных проектов в срок
        # Учитывать для роли координатор от Проектного офиса путем отсутствия мероприятий в статусе «На проверке»
        # на момент достижения сроков выполнения мероприятия
        # from work_packages: если due_date < current_date and status=на проверке
        # если >1 - 0%, иначе 1-%
        # Осуществление мониторинга региональных проектов в срок – 10%
        { name: I18n.t(:default_kpi_monitoring), role: I18n.t(:default_role_project_office_coordinator), percent: 10, min_value: 0, max_value: 0,enable: true, period: "" },


        # 6.	Количество завершенных проектов
        # Учитывать количество завершенных проектов за год, в которых пользователь имеет одну из следующих ролей:
        # куратор проекта, руководитель проекта, администратор проекта, координатор от Проектного офиса
        # 1-5 в год – 10%
        # 5-10 в гол – 15%
        { name: I18n.t(:default_kpi_closed_project), role: I18n.t(:default_role_project_curator), percent: 10, min_value: 1, max_value: 5,enable: true, period: "Yearly" },
        { name: I18n.t(:default_kpi_closed_project), role: I18n.t(:default_role_project_curator), percent: 15, min_value: 6, max_value: 10,enable: true, period: "Yearly" },

        { name: I18n.t(:default_kpi_closed_project), role: I18n.t(:default_role_project_head), percent: 10, min_value: 1, max_value: 5,enable: true, period: "Yearly" },
        { name: I18n.t(:default_kpi_closed_project), role: I18n.t(:default_role_project_head), percent: 15, min_value: 6, max_value: 10,enable: true, period: "Yearly" },

        { name: I18n.t(:default_kpi_closed_project), role: I18n.t(:default_role_project_office_coordinator), percent: 10, min_value: 1, max_value: 5,enable: true, period: "Yearly" },
        { name: I18n.t(:default_kpi_closed_project), role: I18n.t(:default_role_project_office_coordinator), percent: 15, min_value: 6, max_value: 10,enable: true, period: "Yearly" },

        { name: I18n.t(:default_kpi_closed_project), role: I18n.t(:default_role_project_admin), percent: 10, min_value: 1, max_value: 5,enable: true, period: "Yearly" },
        { name: I18n.t(:default_kpi_closed_project), role: I18n.t(:default_role_project_admin), percent: 15, min_value: 6, max_value: 10,enable: true, period: "Yearly" },

        # 7.	Количество внесенных в реестр рисков
        # Учитывать количество рисков в реестре рисков для ролей: куратор проекта, руководитель проекта, администратор проекта,
        # координатор от Проектного офиса
        # 5-8 - 10%
        # 8-15 – 15%
        { name: I18n.t(:default_kpi_saved_risks), role: I18n.t(:default_role_project_curator), percent: 10, min_value: 5, max_value: 8,enable: true, period: "" },
        { name: I18n.t(:default_kpi_saved_risks), role: I18n.t(:default_role_project_curator), percent: 10, min_value: 6, max_value: 15,enable: true, period: "" },

        { name: I18n.t(:default_kpi_saved_risks), role: I18n.t(:default_role_project_head), percent: 10, min_value: 5, max_value: 8,enable: true, period: "" },
        { name: I18n.t(:default_kpi_saved_risks), role: I18n.t(:default_role_project_head), percent: 10, min_value: 6, max_value: 15,enable: true, period: "" },

        { name: I18n.t(:default_kpi_saved_risks), role: I18n.t(:default_role_project_office_coordinator), percent: 10, min_value: 5, max_value: 8,enable: true, period: "" },
        { name: I18n.t(:default_kpi_saved_risks), role: I18n.t(:default_role_project_office_coordinator), percent: 10, min_value: 6, max_value: 15,enable: true, period: "" },

        { name: I18n.t(:default_kpi_saved_risks), role: I18n.t(:default_role_project_admin), percent: 10, min_value: 5, max_value: 8,enable: true, period: "" },
        { name: I18n.t(:default_kpi_saved_risks), role: I18n.t(:default_role_project_admin), percent: 10, min_value: 6, max_value: 15,enable: true, period: "" },

        { name: I18n.t(:default_kpi_saved_risks), role: I18n.t(:default_role_events_responsible), percent: 10, min_value: 5, max_value: 8,enable: true, period: "" },
        { name: I18n.t(:default_kpi_saved_risks), role: I18n.t(:default_role_events_responsible), percent: 10, min_value: 6, max_value: 15,enable: true, period: "" },

        # 8.	Количество проведенных мероприятий направленных на минимизацию рисков.
        #   Учитывать количество решенных за месяц рисков и проблем в мероприятиях для ролей: куратор проекта,
        # руководитель проекта, администратор проекта, координатор от Проектного офиса по проекту в целом,
        # для ролей ответственный за блок мероприятий, исполнитель, по назначенным им мероприятиям.
        # 1-3 в месяц – 10%
        # 3-7 в месяц – 15 %
        # 7 и более – 25%
        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_project_curator), percent: 10, min_value: 1, max_value: 3,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_project_curator), percent: 15, min_value: 4, max_value: 7,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_project_curator), percent: 25, min_value: 8, max_value: 9999,enable: true, period: "Monthly" },

        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_project_head), percent: 10, min_value: 1, max_value: 3,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_project_head), percent: 15, min_value: 4, max_value: 7,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_project_head), percent: 25, min_value: 8, max_value: 9999,enable: true, period: "Monthly" },

        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_project_admin), percent: 10, min_value: 1, max_value: 3,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_project_admin), percent: 15, min_value: 4, max_value: 7,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_project_admin), percent: 25, min_value: 8, max_value: 9999,enable: true, period: "Monthly" },

        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_project_office_coordinator), percent: 10, min_value: 1, max_value: 3,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_project_office_coordinator), percent: 15, min_value: 4, max_value: 7,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_project_office_coordinator), percent: 25, min_value: 8, max_value: 9999,enable: true, period: "Monthly" },

        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_events_responsible), percent: 10, min_value: 1, max_value: 3,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_events_responsible), percent: 15, min_value: 4, max_value: 7,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_events_responsible), percent: 25, min_value: 8, max_value: 9999,enable: true, period: "Monthly" },

        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_ispolnitel), percent: 10, min_value: 1, max_value: 3,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_ispolnitel), percent: 15, min_value: 4, max_value: 7,enable: true, period: "Monthly" },
        { name: I18n.t(:default_kpi_minimize_risks), role: I18n.t(:default_role_ispolnitel), percent: 25, min_value: 8, max_value: 9999,enable: true, period: "Monthly" },

        # 9.	Достижение показатели проекта
        # Учитывать те показатели, фактическое значение которых, соответствует плановому
        # Руководитель проекта, куратор проекта
        # 0 - 1 - 10%
        # 2 - 3 – 15%
        # 4 - более – 20%
        { name: I18n.t(:default_kpi_target), role: I18n.t(:default_role_project_curator), percent: 10, min_value: 0, max_value: 1,enable: true, period: "" },
        { name: I18n.t(:default_kpi_target), role: I18n.t(:default_role_project_curator), percent: 10, min_value: 2, max_value: 3,enable: true, period: "" },
        { name: I18n.t(:default_kpi_target), role: I18n.t(:default_role_project_curator), percent: 10, min_value: 4, max_value: 9999,enable: true, period: "" },

        { name: I18n.t(:default_kpi_target), role: I18n.t(:default_role_project_head), percent: 10, min_value: 0, max_value: 1,enable: true, period: "" },
        { name: I18n.t(:default_kpi_target), role: I18n.t(:default_role_project_head), percent: 10, min_value: 2, max_value: 3,enable: true, period: "" },
        { name: I18n.t(:default_kpi_target), role: I18n.t(:default_role_project_head), percent: 10, min_value: 4, max_value: 9999,enable: true, period: "" },

      ]

    end

  end
end
