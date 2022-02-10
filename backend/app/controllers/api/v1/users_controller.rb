class Api::V1::UsersController < ApplicationController
  #before_action :authenticate_user!, only: [:index, :destroy, :update]
  before_action :set_paging, only: [:index]
  before_action :get_user_by_id, only: [:show, :update, :destroy]
  before_action :set_users_search_query, only: [:index]

  USER_MESSAGES = {
    not_exist: "User does not exist",
    not_found: "Has no one user founded yet",
    not_create: "Could not create a new user",
    not_update: "Could not update current user",
    not_remove: "Could not remove current user",
    deleted: "The user has been removed from the system",
  }

  def index
    users = User.all_of(@search_query).limit(@limit).offset(@offset).asc(:id)
    if users.any?
      data = users.map do |user|
        except_data(user, [:password_digest, :_id, :token])
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
        }, status: :ok
    else
      message = {message: USER_MESSAGES[:not_found]}
      render json: message, status: :unprocessable_entity
    end
  end

  def show 
    if @user 
      render json: except_data(@user), status: :ok
    else 
      message = {message: USER_MESSAGES[:not_exist]}
      render json: message, status: :unprocessable_entity
    end
  end

  def new
    user = User.new(user_create_parameters)

    if user.valid? && user.save()
      render json: except_data(user), status: :ok
    else
      message = {message: USER_MESSAGES[:not_create], error: user.errors}
      render json: message, status: :unprocessable_entity
    end
  end

  def update
    if @user 
      if @user.valid? && @user.update(user_update_parameters)
        render json: except_data(@user), status: :ok  
      else 
        message = {message: USER_MESSAGES[:not_update], error: @user.errors}
        render json: message, status: :unprocessable_entity
      end
    else
      message = {message: USER_MESSAGES[:not_exist]}
      render json: message, status: :unprocessable_entity
    end
  end

  def destroy
    if @user 
      if @user.destroy()
        message = {message: USER_MESSAGES[:deleted]}
        render json: message, status: :ok  
      else 
        message = {message: USER_MESSAGES[:not_remove]}
        render json: message, status: :unprocessable_entity
      end
    else 
      message = {message: USER_MESSAGES[:not_exist]}
      render json: message, status: :unprocessable_entity
    end
  end

  private
  def user_create_parameters 
    params.permit(:login, :role, :email, :phone, :password)
  end

  def user_update_parameters 
    params.permit(:id, :login, :description, :email, :phone, :password, address: [:zip, :country, :city, :state, :street])
  end
  
  def get_user_by_id
    @user_id = params.permit(:id)[:id]
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
end
