class AddContractNumToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :contract_num, :string, limit: 30
  end
end
