class CreateCveNistMapping < ActiveRecord::Migration[7.2]
  def change
    create_table :cve_nist_mappings do |t|
      t.string :cve_id
      t.text :nist_control_identifiers
      t.timestamps
    end

    add_index :cve_nist_mappings, :cve_id, unique: true
  end
end
