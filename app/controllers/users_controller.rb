class UsersController < ApplicationController
    before_action :authenticate_admin!

    def authenticate_admin!
        unless @current_user&.admin?
          redirect_to root_path, alert: "You are not authorized to access this page."
        end
    end

    def manage
      search_query = params[:search].to_s.strip.downcase
      @display_users_admin_screen = if search_query.present?
                                       User.where("LOWER(email) LIKE :search OR LOWER(first_name) LIKE :search OR LOWER(last_name) LIKE :search", search: "%#{search_query}%").where.not(id: current_user.id)
                                     else
                                       User.where.not(id: current_user.id)
                                     end
      render partial: 'user_table', locals: { users: @display_users_admin_screen } if request.xhr?
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
