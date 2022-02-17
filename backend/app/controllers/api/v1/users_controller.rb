class Api::V1::UsersController < ApplicationController
  before_action :set_paging, only: [:index] 
  before_action :get_user, only: [:show, :update, :destroy] 
  before_action :set_users_search_query, only: [:index] 
  before_action :get_tokens, only: [:update, :destroy] 

  def index
    begin
      users = User.all_of(@search_query).limit(@limit).offset(@offset).asc(:id)
      escape_with!(:user, :not_exist, :not_found) unless users.any?
      data = users.map do |user|
        except_data!(user)
      end
      records = users.count
      pages = (records.to_f/@limit).ceil
      render json: {
        query: @search_query, 
        limit: @limit, 
        records: records, 
        current_page: @page, 
        total_pages: pages, 
        data: data, 
      }, status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def show 
    begin
      escape_with!(:user, :not_exist, :not_found) unless @user
      render json: except_data!(@user), status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def new
    begin
      escape_with!(:api, :wrong_request, :unprocessable_entity) unless user_create_parameters.present?
      user = User.new(user_create_parameters)
      activation_code = SecureRandom.uuid
      user.activation_code = activation_code
      escape_with!(:user, :invalid_request, :unprocessable_entity, user.errors.full_messages) unless user.valid?
      escape_with!(:user, :not_create, :unprocessable_entity, user.errors.full_messages) unless user.save
      #escape_with!(:api, :activation_send_failure, :precondition_failed, user.activation_code) unless notify_handler(user.as_json, :activation_email)
      TwilioNotifyService.send(user.as_json, :activation_email)
      render_user_data(user)
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def update
    begin
      check_auth!
      escape_with!(:api, :wrong_request, :unprocessable_entity) unless user_update_parameters.present?
      escape_with!(:user, :not_exist, :not_found) unless @user
      check_access!(@user)
      escape_with!(:user, :not_update, :unprocessable_entity, @user.errors.full_messages) unless @user.valid?
      escape_with!(:user, :not_update, :not_acceptable) unless @user.update(user_update_parameters)      
      render_user_data(@user)
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def destroy
    begin
      check_auth!
      escape_with!(:user, :not_exist, :not_found) unless @user
      check_access!(@user)
      escape_with!(:user, :not_remove, :unprocessable_entity) unless @user.destroy
      
      render json: {message: ApiError::MESSAGES[:user][:deleted]}, status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end

  private
  def render_user_data(user)
    render json: except_data!(user), status: :ok and return
  end

  def user_create_parameters 
    params.permit(:login, :role, :email, :phone, :password)
  end

  def user_update_parameters 
    params.permit(:login, :description, :email, :phone, :password, address: [:zip, :country, :city, :state, :street])
  end
  
  def get_user
    @user_login = params[:login]
    @user = User.find_by(login: @user_login)
  end

  def set_users_search_query
    @search_query = {}

    case true
      when !params[:login].nil?
        @search_query[:login] = /.*#{param_to_search(params[:login])}.*/
      when !params[:email].nil?
        @search_query[:email] = /.*#{param_to_search(params[:email])}.*/
      when !params[:phone].nil?
        @search_query[:phone] = /.*#{param_to_search(params[:phone])}.*/
    end
  end
end
