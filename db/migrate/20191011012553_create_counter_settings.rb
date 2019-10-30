class CreateCounterSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :counter_settings do |t| # шаблон счетчика
      t.integer :custom_field_id   #  внешний ключ на настраиваемое поле
      t.string  :template          # шаблон
      t.integer :length            # длина
      t.string  :period         # временные характеристики, периодичность обнуления, старта заново:
      #   Daily     - ежедневно
      #   Weekly    - еженедельно
      #   Monthly   - ежемесячно
      #   Quarterly - ежеквартально
      #   Yearly    - ежегодно
    end

    create_table :counter_values do |t| # значение счетчика
      t.integer :custom_value_id    #  идентификатор значения настраиваемого поля
      t.integer :custom_field_id    #  внешний ключ на настраиваемое поле
      t.integer :counter_setting_id # идентификатор шаблона счетчика
      t.integer :value              # значение счетчика

      t.timestamps
    end
  end
end
