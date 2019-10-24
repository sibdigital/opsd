class AddYearToCosts < ActiveRecord::Migration[5.2]
  def change
    add_column :cost_entries, :plan_year, :integer # год для разбивки бюджета проекта по годам
  end
end
