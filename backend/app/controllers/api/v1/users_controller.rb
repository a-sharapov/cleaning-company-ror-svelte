class Api::V1::UsersController < ApplicationController
  before_action :set_paging, only: [:index] 
  before_action :get_user_by_id, only: [:show, :update, :destroy] 
  before_action :set_users_search_query, only: [:index] 
  before_action :get_tokens, only: [:update, :destroy] 

  def index
    begin
      users = User.all_of(@search_query).limit(@limit).offset(@offset).asc(:id)
      raise ApiError.new(ApiError::MESSAGES[:user][:not_found], :not_found) unless users.any?
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
      raise ApiError.new(ApiError::MESSAGES[:user][:not_exist], :not_found) unless @user
      render json: except_data!(@user), status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def new
    begin
      raise ApiError.new(ApiError::MESSAGES[:api][:wrong_request], :unprocessable_entity) unless user_create_parameters.present?
      user = User.new(user_create_parameters)
      raise ApiError.new(ApiError::MESSAGES[:user][:not_create], :unprocessable_entity, user.errors.full_messages) unless user.valid? && user.save()
      
      notify_handler(user)
      render_user_data(user)
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def update
    begin
      check_auth!
      raise ApiError.new(ApiError::MESSAGES[:api][:wrong_request], :unprocessable_entity) unless user_update_parameters.present?
      raise ApiError.new(ApiError::MESSAGES[:user][:not_exist], :not_found) unless @user
      raise ApiError.new(ApiError::MESSAGES[:user][:not_update], :unprocessable_entity, @user.errors.full_messages) unless @user.valid?
      raise ApiError.new(ApiError::MESSAGES[:user][:not_update], :not_acceptable) unless @user.update(user_update_parameters)
      
      render_user_data(@user)
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def destroy
    begin
      check_auth!
      raise ApiError.new(ApiError::MESSAGES[:user][:not_exist], :not_found) unless @user
      raise ApiError.new(ApiError::MESSAGES[:user][:not_remove], :unprocessable_entity) unless @user.destroy()
      
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
    params.permit(:id, :login, :description, :email, :phone, :password, address: [:zip, :country, :city, :state, :street])
  end
  
  def get_user_by_id
    @user_id = params[:id]
    @user = User.find(@user_id)
  end

  def set_users_search_query
    @search_query = {}

    case true
      when !params[:id].nil?
        @search_query[:id] = param_to_search(params[:id])
      when !params[:login].nil?
        @search_query[:login] = /.*#{param_to_search(params[:login])}.*/
      when !params[:email].nil?
        @search_query[:email] = /.*#{param_to_search(params[:email])}.*/
      when !params[:phone].nil?
        @search_query[:phone] = /.*#{param_to_search(params[:phone])}.*/
    end
  end
  
  def notify_handler(user)
    if user.phone.present? && !user.phone.nil?
      #telegram bot                                                                   
    end
    if user.email.present? && !user.email.nil?
      ApplicationMailer.with(user: user).activation_email.deliver_later
    end
  end
end
