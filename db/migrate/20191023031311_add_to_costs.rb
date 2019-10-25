class AddToCosts < ActiveRecord::Migration[5.2]
  def change

    add_column :cost_objects, :target_id, :integer                  # сслыка targets целевые показатели
    add_column :material_budget_items, :passport_units, :decimal    # предусмотрено паспортом федерального проекта
    add_column :material_budget_items, :consolidate_units, :decimal #  сводная бюджетная роспись
    add_column :cost_entries, :recorded_liability, :decimal # Учтенные бюджетные обязательства
  end
end
