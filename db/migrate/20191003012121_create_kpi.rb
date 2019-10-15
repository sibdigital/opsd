class CreateKpi < ActiveRecord::Migration[5.2]
  def change
    create_table :key_performance_indicators do |t|
      t.string :name                    # наименование  расчета КПИ
      t.decimal :weight, default: 1.0   # вес методики
      t.boolean :enable                 # включена/выключена
      t.string :calc_method             # метод агрегирования:
                        # avg - включается в среднее т.е с другими таким же КПИ берется как среднее значение
                        # sum - суммируется т.е с другими такими же КПИ складывается

      t.timestamps
    end

    create_table :key_performance_indicator_cases do |t|
      t.integer :key_performance_indicator_id   #  расчет КПИ
      t.integer :role_id                        # для какой роли расчет
      t.decimal :percent, default: 1.0          # вес критерия в процентах
      t.decimal :min_value, default: 1.0        # минимальное значение для данного веса
      t.decimal :max_value, default: 1.0        # максимальное значение для данного веса
      t.boolean :enable                         # включен/выключен
      t.string  :period                         # периодичность расчета
                        #   Daily     - ежедневно
                        #   Weekly    - еженедельно
                        #   Monthly   - ежемесячно
                        #   Quarterly - ежеквартально
                        #   Yearly    - ежегодно

      t.timestamps
    end
  end
end
