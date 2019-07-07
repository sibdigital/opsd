class AddEisHrefInContract < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :eis_href, :string
  end
end
