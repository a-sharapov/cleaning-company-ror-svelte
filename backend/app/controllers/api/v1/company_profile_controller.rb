class Api::V1::CompanyProfileController < ApplicationController
  before_action :set_paging, only: [:index] 
  before_action :get_company_profile, only: [:show, :update, :logotype, :partial] 
  before_action :set_profiles_search_query, only: [:index] 
  before_action :get_tokens, only: [:new, :update, :destroy] 

  def index
    begin
      profiles = CompanyProfile.all_of(@search_query).limit(@limit).offset(@offset).asc(:id)
      profiles = profiles.where(service_types: {'$in': params[:service_types]}) if params[:service_types].present?
      escape_with!(:profiles, :not_found, :ok) unless profiles.any?
      data = except_all(profiles)
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

  def show
    begin
      escape_with!(:profiles, :not_exist, :not_found) unless @profile
      render_data(@profile)
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def show_to_user
    begin
      user = prepare_user!
      escape_with!(:profiles, :not_exist, :ok) unless profile = CompanyProfile.find_by(user_id: user.id)
      render_data(profile)
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def new
    begin
      user = prepare_user!
      escape_with!(:profiles, :already_exist, :ok) if CompanyProfile.find_by(user_id: user.id)
      profile = CompanyProfile.new(company_profile_parameters)
      profile.user = user
      escape_with!(:api, :invalid_request, :ok, profile.errors.full_messages) unless profile.valid? && profile.update(company_profile_parameters)
      render_data(profile)
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def update
    begin
      user = prepare_user!
      escape_with!(:profiles, :not_exist, :ok) unless @profile
      escape_with!(:api, :invalid_request, :ok, @profile.errors.full_messages) unless @profile.valid? && @profile.update(company_profile_parameters.merge({slug: Translit.convert(params[:company_name], :english).parameterize}))
      render_data(@profile)
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def logotype
    begin
      escape_with!(:profiles, :not_exist, :not_found) unless @profile
      logo_path = "public/system/company_profiles/logotypes/original/#{params[:image]}"
      escape_with!(:profiles, :logo_not_exist, :not_found) unless File.exist?(logo_path)
      send_file(logo_path, type: @profile.logotype_content_type, disposition: 'inline')
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def search
    begin
      search_query = /.*#{param_to_search(params[:q])}.*/
      profiles = CompanyProfile.full_text_search(search_query)
      escape_with!(:profiles, :not_found, :ok) unless profiles.any?
      output = []
      profiles.map do |profile|
        output << profile.company_name
      end
      render json: output, status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def partial
    begin
      escape_with!(:profiles, :not_found, :ok) unless @profile.present?
      type = params[:type]
      safety = except_data! @profile
      render json: safety[type], status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end

  private
  def company_profile_parameters
    params.permit(
      :logotype, 
      :company_name, 
      :description, 
      address: [
        :zip, 
        :country, 
        :city, 
        :state, 
        :street
      ],
      service_types: [],
      prices: {}
    )
  end

  def get_company_profile
    @slug = params[:slug]
    @profile = CompanyProfile.find_by(slug: @slug)
    @profile = CompanyProfile.find_by(company_name: @slug) unless @profile
  end

  def set_profiles_search_query
    @search_query = {}

    case true
      when !params[:company_name].nil?
        @search_query[:company_name] = /.*#{param_to_search(params[:company_name])}.*/
      when !params[:street].nil?
        @search_query[:'address.street'] = /.*#{param_to_search(params[:street])}.*/
      when !params[:city].nil?
        @search_query[:'address.city'] = /.*#{param_to_search(params[:city])}.*/
    end
  end
end
