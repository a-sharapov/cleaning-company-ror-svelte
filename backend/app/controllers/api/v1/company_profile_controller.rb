class Api::V1::CompanyProfileController < ApplicationController
  before_action :set_paging, only: [:index] 
  before_action :get_company_profile, only: [:show, :update, :destroy] 
  before_action :set_profiles_search_query, only: [:index] 
  before_action :get_tokens, only: [:new, :update, :destroy] 

  def index
    begin
      profiles = CompanyProfile.all_of(@search_query).limit(@limit).offset(@offset).asc(:id)
      escape_with!(:profiles, :not_found, :not_found) unless profiles.any?
      data = profiles.map do |profile|
        except_data!(profile)
      end
      records = profiles.count
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

  def new
    begin
      check_auth!
      user = User.find_by(login: user_from_token)
      escape_if_in_blacklist(user)
      check_access!(user)
      profile = CompanyProfile.new(company_profile_parameters)
      profile.user = user
      
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def show
    begin
      
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def update
    begin
      
    rescue ApiError => e
      render_api_error(e)
    end
  end

  # def destroy
  #   begin
  #   // destroyed with user 
  #   rescue ApiError => e
  #     render_api_error(e)
  #   end
  # end

  private
  def company_profile_parameters
    params.permit(
      :logotype, 
      :company_name, 
      :description,
      :service_types, 
      :prices,  
      address: [
        :zip, 
        :country, 
        :city, 
        :state, 
        :street] 
      )
  end

  def get_company_profile
    @company_name = params[:company_name]
    @profile = CompanyProfile.find_by(company_name: @company_name)
  end

  def set_profiles_search_query
    @search_query = {}

    case true
      when !params[:company_name].nil?
        @search_query[:company_name] = /.*#{param_to_search(params[:company_name])}.*/
      when !params[:service_types].nil?
        @search_query[:service_types] = /.*#{param_to_search(params[:service_types])}.*/
      when !params[:prices].nil?
        @search_query[:prices] = /.*#{param_to_search(params[:prices])}.*/
    end
  end
end
