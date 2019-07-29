class AddWorkPackagesAttributes < ActiveRecord::Migration[5.2]
  def change

    #целевые показатели пакета работ/мероприятия
    #связанная таблица c work_packages
    create_table :work_package_targets do |t|
      t.integer :project_id, null: false # идентифткатор проекта, ссылка на projects  заполняется исходя из work_package_id, сделано для удобства выборки(денормализация)
      t.integer :work_package_id, null: false #идентификатор пакета работ
      t.integer :target_id, null: false # идентификатор целевого показателя
      t.integer :year, null: false # год
      t.integer :quarter # квартал,если заполняется только квартал, то месяц не заполняется
      t.integer :month # месяц. если заполняется месяц то надо заполнить и квартал
      t.decimal :value # значение показателя текущее
      t.string  :type # тип Template - на случай, если к пакету работ будут добавляться показатели, которые надо заполнить для них указывается
        # только project_id, work_package_id, target_id
        # Report - показатели, которые внес ответственный сам

      t.timestamps
    end

    #рискик/проблемы пакета работ/мероприятия
    #для внесения информациии о рисках и проблемах
    create_table :work_package_problems do |t|
      t.integer :project_id, null: false # идентифткатор проекта, ссылка на projects  заполняется исходя из work_package_id, сделано для удобства выборки(денормализация)
      t.integer :work_package_id, null: false #идентификатор пакета работ
      t.integer :user_creator_id, null: false #идентификатор пользователя, который вводит риск/проблему ссылка на users
      t.integer :risk_id, null: false # идентификатор риска (заполняется если это риск type=Risk, а не проблема) - ссылка на risks
      t.integer :user_source_id, null: false # идентификатор пользователя-источника проблемы/риска ссылка на users
      t.integer :organization_source_id, null: false # идентификатор организации-источника проблемы/риска  ссылка на organizations
      t.string  :description # текстовое описание
      t.string  :status # статус решения: created - создан, solved- решен
      t.integer :solution_date # дата решения
      t.string  :type # Risk - риск, Problem - проблема,

      t.timestamps
    end
  end
end
