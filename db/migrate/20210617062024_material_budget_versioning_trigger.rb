class MaterialBudgetVersioningTrigger < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
    ALTER TABLE public.material_budget_items
    ADD COLUMN IF NOT EXISTS sys_period tstzrange NOT NULL DEFAULT tstzrange(current_timestamp, null);

    CREATE TABLE IF NOT EXISTS material_budget_items_history (LIKE public.material_budget_items);
    
    CREATE TRIGGER versioning_trigger
    BEFORE INSERT OR UPDATE OR DELETE ON material_budget_items
    FOR EACH ROW EXECUTE PROCEDURE versioning(
    'sys_period', 'material_budget_items_history', true
    );
    SQL
  end
end
