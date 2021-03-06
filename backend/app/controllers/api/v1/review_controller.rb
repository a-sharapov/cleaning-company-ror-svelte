class Api::V1::ReviewController < ApplicationController
  before_action :set_paging, only: [:index] 
  before_action :set_reviews_search_query, only: [:index] 
  before_action :get_tokens, only: [:update] 
  before_action :get_review, only: [:show, :update] 
  before_action :get_user_by_login, only: [:new] 

  def index
    begin
      reviews = Review.all_of(@search_query).limit(@limit).offset(@offset).asc(:id)
      reviews = reviews.where(assessment: {'$in': params[:review_type].split(',')}) if params[:review_type].present?
      escape_with!(:reviews, :not_found, :ok) unless reviews.any?
      data = except_all(reviews)
      records = reviews.count
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
      escape_with!(:reviews, :not_exist, :ok) unless @review
      render_data(@review)
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def new
    begin
      if @user
        escape_with!(:reviews, :self, :ok) if @user.company_profile.company_name.eql?(review_parameters[:company_name])
        escape_with!(:reviews, :already_exist, :ok) if Review.find_by({customer: review_parameters[:customer], company_name: review_parameters[:company_name]})
      end
      escape_with!(:reviews, :already_exist, :ok) if Review.find_by(description: review_parameters[:description])
      review = Review.new(review_parameters)
      company = CompanyProfile.find_by(company_name: review_parameters[:company_name])
      escape_with!(:profiles, :not_exist, :ok) unless company
      review.company_profile = company
      escape_with!(:api, :invalid_request, :ok, review.errors.full_messages) unless review.valid? && review.save()
      render json: {
        message: ApiError::MESSAGES[:reviews][:created],
        review: except_data!(review)
      }, status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def update
    begin
      user = prepare_user!
      escape_with!(:reviews, :not_exist, :ok) unless @review
      escape_with!(:api, :invalid_request, :ok, @review.errors.full_messages) unless @review.valid? && @review.update(review_parameters)
      render_data(@review)
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def raiting
    begin
      company = CompanyProfile.find_by(slug: params[:slug])
      escape_with!(:profiles, :not_exist, :ok) unless company
      reviews = Review.all_of(company_name: company.company_name)
      records = reviews.count
      if records > 0
        assessment = 0
        reviews.each do |review|
          assessment += review.assessment.to_i
        end
        average = (assessment.to_f/records.to_f).ceil(2)
        message = {
          count: records,
          assessment: average
        }
      else
        message = {
          count: 0,
          assessment: 5
        }
      end
      render json: message, status: :ok and return 
    rescue ApiError => e
      render_api_error(e)
    end
  end

  private
  def review_parameters
    params.permit(
      :customer,
      :company_name,
      :description,
      :assessment,
      assets: [
        
      ]
    )
  end

  def get_review
    @slug = params[:slug]
    @review = Review.find_by(slug: @slug)
  end

  def get_user_by_login
    login = review_parameters[:customer]
    @user = User.find_by(login: login)
    @user = User.find_by(email: login) unless @user
    @user = User.find_by(phone: login) unless @user
  end

  def set_reviews_search_query
    @search_query = {}

    case true
      when !params[:company_name].nil?
        @search_query[:company_name] = /.*#{param_to_search(params[:company_name])}.*/
    end
  end
end
