class Api::V1::CleaningEventController < ApplicationController
  before_action :set_paging, only: [:index] 
  before_action :set_events_search_query, only: [:index] 
  before_action :get_tokens, only: [:update, :destroy] 

  def index
    begin
      
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
  
  def new
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
  
  def destroy
    begin
      
    rescue ApiError => e
      render_api_error(e)
    end
  end

  private
  def set_events_search_query
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