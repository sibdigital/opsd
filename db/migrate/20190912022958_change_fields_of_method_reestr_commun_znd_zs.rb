class ChangeFieldsOfMethodReestrCommunZndZs < ActiveRecord::Migration[5.2]
  def change
    remove_column :targets, :basic_data
    add_column :targets, :basic_date, :date #дата на которую указан базовый показатель
    remove_column :targets, :plan_data
    add_column :targets, :plan_date, :date #дата на которую планируется достижение планового значения

    remove_column :target_calc_procedures, :uroven
    add_column :target_calc_procedures, :level, :string # переименовал

    remove_column :communication_requirements, :kinf_info
    add_column :communication_requirements, :kind_info, :string
  end
end
