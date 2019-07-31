class CreateRaionAndVdl < ActiveRecord::Migration[5.2]
  def change
    #Справочник районов
    create_table :raions do |t|
      t.string  :name # наименование
      t.string  :code # код
      t.integer :sort_code # код для сортировки
    end

    #Показатели деятельности высшего должностного лица
    create_table :head_performance_indicators do |t|
      t.string :name # наименование
      t.integer :measure_unit_id # единица измерения, если нужна
      t.integer :sort_code # код для сортировки
      t.boolean :active #признак использования
    end


    #Значения показателей деятельности
    create_table :head_performance_indicator_values do |t|
      t.integer :head_performance_indicator_id # Показатель деятельности
      t.string  :type # Planning - плановый показатель, Execution - фактический показатель
                      # - на текущий момент используются только фактические
      t.integer :year, null: false # год
      t.integer :quarter # квартал,если заполняется только квартал, то месяц не заполняется
      t.integer :month # месяц. если заполняется месяц то надо заполнить и квартал
      t.decimal :value # значение показателя текущее
      t.integer :sort_code # код сортировки
    end

    #добавляем район в пакет работ
    add_column :work_packages, :raion_id, :integer
  end
end
