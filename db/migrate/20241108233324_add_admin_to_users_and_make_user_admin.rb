class AddAdminToUsersAndMakeUserAdmin < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :admin, :boolean, default: false, null: false

    User.reset_column_information
    User.find_by(email: 'vasudha.devarakonda@tamu.edu')&.update(admin: true)
  end
end
