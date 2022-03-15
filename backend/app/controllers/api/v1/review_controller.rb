class Api::V1::ReviewController < ApplicationController
  before_action :set_paging, only: [:index] 
  before_action :set_reviews_search_query, only: [:index] 
  before_action :get_tokens, only: [:update] 
  before_action :get_review, only: [:show, :update] 

  def index
    begin
      reviews = Review.all_of(@search_query).limit(@limit).offset(@offset).asc(:id)
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
      user = prepare_user!
      escape_with!(:reviews, :already_exist, :ok) if Review.find_by(customer: user.login)
      review = Review.new(review_parameters)
      review.customer = user ? user.login : "Anonymous"
      company = CompanyProfile.find_by(company_name: review_parameters[:company_name])
      escape_with!(:profiles, :not_exist, :ok, review.errors.full_messages) unless company
      review.company_profile = company
      escape_with!(:reviews, :already_exist, :ok) if Review.find_by(customer: user.login, company_name: review_parameters[:company_name])
      escape_with!(:api, :invalid_request, :ok, review.errors.full_messages) unless review.valid? && review.save()
      render_data(review)
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
        average = (assessment.to_i/records.to_i).ceil
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

  def set_reviews_search_query
    @search_query = {}

    case true
      when !params[:company_name].nil?
        @search_query[:company_name] = /.*#{param_to_search(params[:company_name])}.*/
      when !params[:customer].nil?
        @search_query[:customer] = /.*#{param_to_search(params[:customer])}.*/
      when !params[:assessment].nil?
        @search_query[:assessment] = param_to_search(params[:assessment])
    end
  end
end
