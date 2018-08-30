module Trestle
  module Auth
    module ControllerMethods
      extend ActiveSupport::Concern
      
      included do
        include Pundit
        before_action :authenticate_user!, except: [:show, :index]
        before_action :set_paper_trail_whodunnit
        before_action :require_super_admin!, only: [:destroy]
        before_action :require_edit_permissions!, only: [:new, :create, :update]

        def guest_user
          return @guest_user if @guest_user
          if session[:guest_user_id]
            @guest_user = User.find_by(User.authentication_keys.first => session[:guest_user_id]) rescue nil
            @guest_user = nil if @guest_user.respond_to? :guest and !@guest_user.guest 
          end
          @guest_user ||= begin
            u = create_guest_user(session[:guest_user_id])
            session[:guest_user_id] = u.send(User.authentication_keys.first)
            u
          end
          @guest_user
        end
        def current_or_guest_user
          # puts "test"
          if current_user.present?
            if session[:guest_user_id].present?
              # byebug

              guest_user.destroy
              session[:guest_user_id] = nil
              # run_callbacks :logging_in_user do
              #   guest_user.destroy
              #   session[:guest_user_id] = nil
              # end
            end
            current_user
          else
            guest_user
          end
        end
      end

      protected
      def require_edit_permissions!
        if current_or_guest_user.is_visitor?
          render "unauthorized" 
          return
        end
      end

      def require_super_admin!
        unless current_or_guest_user.is_super_admin?
          render "unauthorized" 
          return
        end
      end
    end
  end
end