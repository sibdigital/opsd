class CreateOrganizationCustomFields < ActiveRecord::Migration[5.2]
  def change
    create_table :organization_custom_fields do |t|

      t.timestamps
    end
  end
end
