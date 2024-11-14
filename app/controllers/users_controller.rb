class UsersController < ApplicationController
    before_action :authenticate_admin!

    def authenticate_admin!
        unless @current_user&.admin?
          redirect_to root_path, alert: "You are not authorized to access this page."
        end
    end

    def manage
      @display_users_admin_screen = User.where.not(id: current_user.id)
    end

    def update_admin_status
        admin_user_ids = params[:admin_user_ids] || []

        block_user_ids = params[:block_user_ids] || []
    
        User.where.not(id: current_user.id).find_each do |user|
          user.update(admin: admin_user_ids.include?(user.id.to_s))
        end

        User.where.not(id: current_user.id).find_each do |user|
          user.update(block: block_user_ids.include?(user.id.to_s))
        end

        redirect_to root_path, notice: "User statuses updated successfully."
    end

    def destroy
      user = User.find(params[:id])
      user.destroy
      redirect_to manage_users_path, notice: "User deleted successfully."
    end
end
