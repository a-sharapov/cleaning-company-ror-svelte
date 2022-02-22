class Api::V1::ReviewController < ApplicationController
  before_action :set_paging, only: [:index] 
  before_action :set_reviews_search_query, only: [:index] 
  before_action :get_tokens, only: [:update, :destroy] 


  private
  def set_reviews_search_query

  end
end
