class AddAdminToUsersAndMakeUserAdmin < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :admin, :boolean, default: false, null: false

    User.reset_column_information
    User.find_by(email: 'sf08@tamu.edu')&.update(admin: true)
  end
end
