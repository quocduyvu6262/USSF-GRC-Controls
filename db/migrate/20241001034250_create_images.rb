class CreateImages < ActiveRecord::Migration[7.2]
  def change
    create_table :images do |t|
      t.string :tag
      t.text :report
      t.references :run_time_object, null: false, foreign_key: true

      t.timestamps
    end
  end
end
