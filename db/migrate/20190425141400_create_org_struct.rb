#+-tan 2019.04.25
class CreateOrgStruct < ActiveRecord::Migration[5.2]
  def change
    create_position
  end

  private

  def create_position
    create_table :positions do |t|
      t.string :name

      t.timestamps
    end
  end

end
