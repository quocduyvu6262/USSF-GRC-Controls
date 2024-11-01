class CreateRunTimeObjectsPermissions < ActiveRecord::Migration[6.0]
  def change
    create_table :run_time_objects_permissions do |t|
      t.references :run_time_object, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :permission

      t.timestamps
    end

    add_index :run_time_objects_permissions, [ :run_time_object_id, :user_id ], unique: true, name: 'index_run_time_objects_permissions_on_runtime_and_user'
  end
end
