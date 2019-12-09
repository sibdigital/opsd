module KpiHelper
  include ApplicationHelper

  #1.	Количество открываемых проектов.
  # Учитывать количество проектов за квартал, в которых пользователь имеет одну из следующих ролей:
  # куратор проекта, руководитель проекта, администратор проекта
  # 1.	Количество открываемых проектов:
  # 1-3 проектов в квартал – 10%
  # 3-5 проектов в квартал – 30%
  def calc_kpi_count_opened_project(user)
    kpi = KeyPerformanceIndicator.find_by(:name=>t(:default_kpi_count_opened_project))
    members = members_by_key_performance_indicator_cases(user.id, kpi.id)

    today = Date.today
    result = Project.where(id: [members.map {|m| m['project_id']}],
                           project_status_id: ProjectStatus.find_by(name: "в работе").id,
                           fact_start_date: today.beginning_of_quarter..today)

    val_result = result.present? ? result.count : 0
    percent = percent_by_val(val_result, kpi.id)
    percent.to_s + '%'
  end

  #2.	Количество сопровождаемых проектов.
  #Учитывать текущее количество проектов, в которых пользователь имеет оду из следующих ролей:
  # координатор от Проектного офиса, ответственный за блок мероприятий, исполнитель.
  #5-7 проектов – 10%
  #7-10 – 20%
  #10-15 – 40%
  #15-20 – 50%
  def calc_kpi_count_support_project(user)
    kpi = KeyPerformanceIndicator.find_by(:name=>t(:default_kpi_count_support_project))
    members = members_by_key_performance_indicator_cases(user.id, kpi.id)

    today = Date.today
    result = Project.where(id: [members.map {|m| m['project_id']}],
                           project_status_id: ProjectStatus.find_by(name: "в работе").id,
                           fact_start_date: today.beginning_of_year..today)

    val_result = result.present? ? result.count : 0
    percent = percent_by_val(val_result, kpi.id)
    percent.to_s + '%'
  end

  # 3. Количество организованных совещаний, мероприятий.
  #   Учитывать количество созданных пользователем за квартал совещаний.
  #
  # meetings.author_id
  #
  # 1-10 в квартал – 15%
  # 10 – 20 – 30%
  # 20 и выше – 40%
  def calc_kpi_count_opened_meeting(user)
    kpi = KeyPerformanceIndicator.find_by(:name=>t(:default_kpi_count_opened_meeting))

    today = Date.today
    result = Meeting.where(author_id: user.id,
                           created_at: today.beginning_of_quarter..today)

    val_result = result.present? ? result.count : 0
    percent = percent_by_val(val_result, kpi.id)
    percent.to_s + '%'
  end

  #   4. Отсутствие красных контрольных точек
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
  # в 1 отчетный месяц – 10%
  # в отчетный квартал – 15%
  # в год – 30%
  def calc_kpi_no_red_kt(user)
    # "0%"
    kpi = KeyPerformanceIndicator.find_by(:name=>t(:default_kpi_no_red_kt))
    members = members_by_key_performance_indicator_cases(user.id, kpi.id)

    today = Date.today

    # if куратор проекта, руководитель проекта, администратор проекта,
    #   # координатор от Проектного офиса по проекту в целом
    # select period
    percent = {}

    members.each do |member|

      kpi_period = KeyPerformanceIndicatorCase.where("key_performance_indicator_id = ? and role_id = ? and period <> ''",
                                                     kpi.id,
                                                     member['role_id']).all

      where_assigned_to_id = ""
      if (member['role_id'] == Role.events_responsible.id) || (member['role_id'] == Role.find_by(:name => 'Исполнитель').id)
        where_assigned_to_id = " and (assigned_to_id = " + Member.where('project_id = ? and user_id = ?',
                                                                    member['project_id'], user.id).first.id.to_s + ")"
      end

      if kpi_period.nil?
        result = WorkPackage.where("(project_id = ?) and (not status_id in (?)) and (due_date < ?)" + where_assigned_to_id,
                                   member['project_id'],
                                   [Status.find_by(name: "Завершен"), Status.find_by(name: "Отменен")],
                                   today)
        val_result = result.present? ? result.count : 0
        percent["no_period"] = percent_by_val(val_result, kpi.id)
        #percent.to_s + '%'
      else
        kpi_period.each do |period|
          query_where = "(project_id in (?)) and (not status_id in (?)) and (due_date < ?)" + where_assigned_to_id
          case period.period
          when "Monthly"
            query_where = query_where + " and (extract(month from due_date) = extract(month from date ?))"
          when "Quarterly"
            query_where = query_where + " and (extract(quarter from due_date) = extract(quarter from date ?))"
          when "Yearly"
            query_where = query_where + " and (extract(year from due_date) = extract(year from date ?))"
          end
          result = WorkPackage.where(query_where,
                                     member['project_id'],
                                     [Status.find_by(name: "Завершен"), Status.find_by(name: "Отменен")],
                                     today,
                                     today)
          val_result = result.present? ? result.count : 0
          percent["default_period_" + period.period.to_s.downcase] = [percent_by_val(val_result, kpi.id, period.period),
                                                                      (percent[period.period].nil? ? 0 : percent[period.period])].max
        end
      end
    end

    result_all = 0
    case kpi.calc_method
    when "avg"
      percent.each { |p| result_all += p[1]}
      result_all = (result_all / percent.size).round(2)
    when "sum"
      percent.each { |p| result_all += p[1]}
    else
      percent.each { |p| result_all += p[1]}
    end

    to_html = result_all.to_s + "%"
    to_html
  end

  #   5. Осуществление мониторинга региональных проектов в срок
  # Учитывать для роли координатор от Проектного офиса путем отсутствия мероприятий в статусе «На проверке»
  # на момент достижения сроков выполнения мероприятия
  # from work_packages: если due_date < current_date and status=на проверке
  # если >1 - 0%, иначе 1-%
  # Осуществление мониторинга региональных проектов в срок – 10%
  def calc_kpi_monitoring(user)
    kpi = KeyPerformanceIndicator.find_by(:name=>t(:default_kpi_monitoring))
    members = members_by_key_performance_indicator_cases(user.id, kpi.id)

    today = Date.today
    result = WorkPackage.where("(project_id in (?)) and (status_id = ?) and (due_date < ?)",
                                  members.map {|m| m['project_id']},
                                  Status.find_by(name: "На проверке").id,
                                  today)

    val_result = result.present? ? result.count : 0
    percent = percent_by_val(val_result, kpi.id)
    percent.to_s + '%'
  end

  # 6. Количество завершенных проектов
  # Учитывать количество завершенных проектов за год, в которых пользователь имеет одну из следующих ролей:
  # куратор проекта, руководитель проекта, администратор проекта, координатор от Проектного офиса
  # 1-5 в год – 10%
  # 5-10 в гол – 15%
  def calc_kpi_closed_project(user)
    kpi = KeyPerformanceIndicator.find_by(:name=>t(:default_kpi_closed_project))
    members = members_by_key_performance_indicator_cases(user.id, kpi.id)

    today = Date.today
    result = Project.where(id: [members.map {|m| m['project_id']}],
                           project_status_id: ProjectStatus.find_by(name: "завершен").id,
                           fact_due_date: today.beginning_of_year..today)

    val_result = result.present? ? result.count : 0
    percent = percent_by_val(val_result, kpi.id)
    percent.to_s + '%'
  end


  # 7. Количество внесенных в реестр рисков
  # Учитывать количество рисков в реестре рисков для ролей: куратор проекта, руководитель проекта, администратор проекта,
  # координатор от Проектного офиса
  # 5-8 - 10%
  # 8-15 – 15%
  def calc_kpi_saved_risks(user)
    kpi = KeyPerformanceIndicator.find_by(:name=>t(:default_kpi_saved_risks))
    members = members_by_key_performance_indicator_cases(user.id, kpi.id)

    result = ProjectRisk.where(:project_id=>[members.map {|m| m['project_id']}])
    val_result = result.present? ? result.count : 0

    percent = percent_by_val(val_result, kpi.id)
    percent.to_s + '%'
  end

  # 8. Количество проведенных мероприятий направленных на минимизацию рисков.
  #   Учитывать количество решенных за месяц рисков и проблем в мероприятиях для ролей: куратор проекта,
  # руководитель проекта, администратор проекта, координатор от Проектного офиса по проекту в целом,
  # для ролей ответственный за блок мероприятий, исполнитель, по назначенным им мероприятиям.
  # 1-3 в месяц – 10%
  # 3-7 в месяц – 15 %
  # 7 и более – 25%
  def calc_kpi_minimize_risks(user)
    kpi = KeyPerformanceIndicator.find_by(:name=>t(:default_kpi_minimize_risks))
    members = members_by_key_performance_indicator_cases(user.id, kpi.id)

    #roles = Role.where(name: [I18n.t(:default_role_project_curator), I18n.t(:default_role_project_head),
    #                  I18n.t(:default_role_project_admin), I18n.t(:default_role_project_office_coordinator)]).to_a

    today = Date.today

    result = WorkPackageProblem.where(:project_id=>[members.map {|m| m['project_id']}],
                                      status: "solved",
                                      solution_date: today.beginning_of_month..today)
    val_result = result.present? ? result.count : 0

    percent = percent_by_val(val_result, kpi.id)
    percent.to_s + '%'
  end

  # 9. Достижение показатели проекта
  # Учитывать те показатели, фактическое значение которых, соответствует плановому
  # Руководитель проекта, куратор проекта
  # 0 - 1 - 10%
  # 2 - 3 – 15%
  # 4 - более – 20%
  def calc_kpi_target(user)
    # kpi = KeyPerformanceIndicator.find_by(:name=>t(:default_kpi_target))
    # members = members_by_key_performance_indicator_cases(user.id, kpi.id)
    #
    # today = Date.today
    # result = WorkPackageTarget.where("",
    #                        year: today.year)
    #
    # val_result = result.present? ? result.count : 0
    # percent = percent_by_val(val_result, kpi.id)
    # percent.to_s + '%'
    "0%"

  end

  private

  def members_by_key_performance_indicator_cases(user_id, kpi_id)
    sql = <<-SQL
      select distinct m.role_id, project_id from member_roles as m
      inner join (
        select id, project_id
        from members as mb
        where mb.user_id = #{ActiveRecord::Base.sanitize_sql(user_id)}
      ) as mb
      on m.member_id = mb.id
      inner join (
        select *
        from key_performance_indicator_cases as k
        where k.key_performance_indicator_id = #{ActiveRecord::Base.sanitize_sql(kpi_id)}
      ) as kpi
      on m.role_id = kpi.role_id
      inner join (
        select *
        from projects
        where type = '#{Project::TYPE_PROJECT}' and status = #{Project::STATUS_ACTIVE}
      ) as prj
      on mb.project_id = prj.id
    SQL
    # MemberRole.where(sql, user_id, kpi_id)
    # query = sanitize_sql([sql, params[user_id, kpi_id]])
    result = ActiveRecord::Base.connection.execute(sql)
    result
  end

  def percent_by_val(val, kpi_id, period = nil)
    # sql = <<-SQL
    #   select max(percent) as percent from key_performance_indicator_cases as kc
    #   where kc.key_performance_indicator_id = ? and ? >= kc.min_value and ? <= kc.max_value
    # SQL
    # result = ActiveRecord::Base.connection.execute(sql, kpi_id, val, val)

    if period.nil?
      result = KeyPerformanceIndicatorCase.where("key_performance_indicator_id = ? and ? >= min_value and ? <= max_value and enable = true",
                                      kpi_id, val, val).maximum(:percent)
    else
      result = KeyPerformanceIndicatorCase.where("key_performance_indicator_id = ? and ? >= min_value and ? <= max_value and enable = true and period = ?",
                                                 kpi_id, val, val, period).maximum(:percent)
    end
    val_result = result.present? ? result : 0
    val_result
  end
end
