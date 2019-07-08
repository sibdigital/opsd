class AddContractFields < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :name, :string
    add_column :contracts, :sposob, :string
    add_column :contracts, :gos_zakaz, :string
    add_column :contracts, :date_begin, :date
    add_column :contracts, :date_end, :date
    add_column :contracts, :etaps, :string
    add_column :organizations, :org_prav_forma, :string
    add_column :organizations, :ur_addr, :string
    add_column :organizations, :post_addr, :string
    add_column :organizations, :otrasl, :string
    add_column :organizations, :gorod, :string
    add_column :organizations, :capital, :string
  end
end
