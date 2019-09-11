class CreateMethodReestrCommunAndZs < ActiveRecord::Migration[5.2]

  def change

    add_column :targets, :is_additional, :boolean #определяет является ли показатель основным или дополнительным,
    # если истина то дополнительный
    add_column :targets, :basic_data, :date #дата на которую указан базовый показатель
    add_column :targets, :plan_data, :date #дата на которую планируется достижение планового значения
    #

    # методика расчета
    create_table :target_calc_procedures do |t|
      t.string  :name           # наименование методики
      t.integer :project_id     # проект
      t.integer :target_id      # идентификатор целевого показателя, котормоу сопоставлена методика
      t.string  :description    # описание методики
      t.integer :base_target_id # базовый целевой показатель
      t.string  :data_source    # источник данных
      t.integer :user_id        # ответственный за сбор данных
      t.string  :uroven         # уровень агрегирования информации
      t.string  :period         # временные характеристики, периодичность сбора  строковые значения:
                                #   Daily     - ежедневно
                                #   Weekly    - еженедельно
                                #   Monthly   - ежемесячно
                                #   Quarterly - ежеквартально
                                #   Yearly    - ежегодно
      t.string  :add_info       # доп. информация

      t.timestamps
    end

    # Заинтерсованные стороны проекта
    # Заинтересованная сторона - это пользователь, организация или внешняя азинетерсованная сторона указанная в данной таблице
    create_table :stakeholders do |t|
      t.string  :name           # наименование ЗС
      t.integer :project_id     # проект
      t.integer :organization_id      # идентификатор органиазции
      t.integer :user_id              # идентификатор пользователя
      t.string  :description    # описание заинтерсованной стороны
      t.string  :type #тип для разделения на типовые и проектный ЗС: UserStakeholder OrganizationStakeholder, OuterStakeholder

      #контакты для внешних заинтерсованных сторон
      t.string  :phone_wrk
      t.string  :phone_wrk_add
      t.string  :phone_mobile
      t.string  :mail_add
      t.string  :address
      t.string  :cabinet

      t.timestamps
    end

    # Для контактной информации заинтересованных сторон - организаций
    add_column :organizations, :phone_wrk, :string
    add_column :organizations, :phone_wrk_add, :string
    add_column :organizations, :phone_mobile, :string
    add_column :organizations, :mail_add, :string
    add_column :organizations, :address, :string
    add_column :organizations, :cabinet, :string

    # План коммуникаций
    # Список информационных потребностей
    create_table :communication_requirements do |t|
      t.string  :name                # наименование
      t.integer :project_id          # проект
      t.integer :stakeholder_id      # идентификатор ЗС
      t.string  :kinf_info    # Вид направляемой информации;
      t.string  :period       #	Периодичность направляемой информации. строковые значения:
                #   Daily     - ежедневно
                #   Weekly    - еженедельно
                #   Monthly   - ежемесячно
                #   Quarterly - ежеквартально
                #   Yearly    - ежегодно

      t.timestamps
    end

    # Список встреч
    create_table :communication_meetings do |t|
      t.string  :name           # наименование
      t.integer :project_id     # проект
      t.string  :kind      # встречa или совещаниe: Meet, Conference
      t.integer :user_id   # Ответственного за организацию встречи или совещания;
      t.string  :theme    # Тему встречи или совещания (при необходимости);
      t.string  :place    # 	Место проведения;
      t.string  :sposob   # очное, с использованием дистанционных технологий или в виде обсуждения в Системе: Fulltime, Remote, System
      t.string  :period #тo	Периодичность направляемой информации. строковые значения:
      #   Daily     - ежедневно
      #   Weekly    - еженедельно
      #   Monthly   - ежемесячно
      #   Quarterly - ежеквартально
      #   Yearly    - ежегодно

      t.timestamps
    end

    # Участники элемента плана коммуникации
    create_table :communication_meeting_members do |t|
      t.integer :project_id                 # проект
      t.integer :stakeholder_id             # идентификатор ЗС
      t.integer :communication_meeting_id   # к какому элементу плана коммуникации относится
    end
   end

end
