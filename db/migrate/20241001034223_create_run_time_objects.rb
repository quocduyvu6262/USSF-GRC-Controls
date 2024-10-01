class CreateRunTimeObjects < ActiveRecord::Migration[7.2]
  def change
    create_table :run_time_objects do |t|
      t.string :name
      t.text :description
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
