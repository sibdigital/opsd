class AddYearsToMateriaBudgetItems < ActiveRecord::Migration[5.2]
  def change
    add_column :material_budget_items, :plan_year, :integer # год для разбивки бюджета проекта по годам
  end
end
