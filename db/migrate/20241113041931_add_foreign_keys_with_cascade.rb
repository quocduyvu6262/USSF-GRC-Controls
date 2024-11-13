class AddForeignKeysWithCascade < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :run_time_objects, :users, on_delete: :cascade

    add_foreign_key :run_time_objects_permissions, :users, on_delete: :cascade
  end
end
