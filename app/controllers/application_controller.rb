class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  before_action :authenticate_admin
  
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  
  protected

  def current_user
    @user
  end
  
  def current_admin
    @admin
  end

  private

  def authenticate_admin
    authenticate_admin_with_token || render_unauthorized_request
  end

  def authenticate_user
    authenticate_user_with_token || render_unauthorized_request
  end

  def authenticate_admin_with_token
    authenticate_with_http_token do |token, options|
      @admin = User.find_by(api_key: token, admin: true)
    end
  end
  
  def authenticate_user_with_token
    authenticate_with_http_token do |token, options|
      @user = User.find_by(api_key: token)
    end
  end

  def render_unauthorized_request
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: { error: 'Bad credentials' }, status: 401
  end
  
  def record_not_found
    render json: { error: 'Record not found' }, status: 404
  end
end
