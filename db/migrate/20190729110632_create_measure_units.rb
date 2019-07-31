class CreateMeasureUnits < ActiveRecord::Migration[5.2]
  def change
    #справочник единиц измерения
    create_table :measure_units do |t|
      t.string :name # полное наименование килограмм, метр, метр квадратный
      t.string :short_name #краткое наименование например кг, м, м2
      t.string :okei_code
    end

    add_column :targets, :measure_unit_id, :integer
  end
end
