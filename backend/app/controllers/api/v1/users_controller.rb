class Api::V1::UsersController < ApplicationController
  #before_action :check_token!, only: [:get_users, :delete_user]
  before_action :set_paging, only: [:get_users]
  before_action :set_users_search_query, only: [:get_users]
  before_action :get_user_by_id, only: [:get_user, :update_user, :delete_user]

  def get_user 
    if @user 
      render json: @user, status: :ok
    else 
      message = {message: "User with ID: #{@user_id} not exist"}
      render json: message, status: :unprocessable_entity
    end
  end

  def get_users
    users = User.all_of(@search_query).limit(@limit).offset(@offset).asc(:id)
    if users.any?
      out = users.map do |user|
        except_data(user, [:password_digest, :_id, :token])
      end
      records = users.count
      pages = (records.to_f/@limit).ceil
      render json: {query: @search_query, limit: @limit, records: records, current_page: @page, total_pages: pages, data: out}, status: :ok
    else
      message = {message: "No one user found yet"}
      render json: message, status: :unprocessable_entity
    end
  end

  def create_user
    user = User.new(user_create_parameters)

    if user.valid? && user.save()
      render json: except_data(user), status: :ok
    else
      message = {message: "Could not create a new user", error: user.errors}
      render json: message, status: :unprocessable_entity
    end
  end

  def update_user
    if @user 
      if @user.valid? && @user.update(user_update_parameters)
        render json: except_data(@user), status: :ok  
      else 
        message = {message: "Could not update user with ID: #{@user_id}", error: @user.errors}
        render json: message, status: :unprocessable_entity
      end
    else
      message = {message: "User with same ID does not exist"}
      render json: message, status: :unprocessable_entity
    end
  end

  def delete_user
    if @user 
      if @user.destroy()
        message = {message: "User with ID: #{@user_id} currently deleted"}
        render json: message, status: :ok  
      else 
        message = {message: "Could not remove user with same ID"}
        render json: message, status: :unprocessable_entity
      end
    else 
      message = {message: "User with same ID does not exist"}
      render json: message, status: :unprocessable_entity
    end
  end

  private
  def user_create_parameters 
    params.permit(:login, :role, :email, :phone, :password)
  end

  def user_update_parameters
    params.permit(:login, :description, :email, :phone, :password, address: [:zip, :country, :city, :state, :street])
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
end
