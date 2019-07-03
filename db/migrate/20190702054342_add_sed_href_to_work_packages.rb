class AddSedHrefToWorkPackages < ActiveRecord::Migration[5.2]
  def change
    add_column :work_packages, :sed_href, :string
  end
end
