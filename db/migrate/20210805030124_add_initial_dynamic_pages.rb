class AddInitialDynamicPages < ActiveRecord::Migration[5.2]
  def up
    DynamicPage.create(content: nil)
  end
end
