class AddBlockToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :block, :boolean, default: false, null: false
  end
end
