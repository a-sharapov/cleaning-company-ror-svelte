class Api::V1::ApiController < ApplicationController

  API_MESSAGES = {
    working: "API server currently working...",
  }
  
  def index
    render json: {message: API_MESSAGES[:working] }, status: :ok
  end

  def endpoints 
    message = {
      "available_endpoints": [
        "users",
        "auth",
      ]
    }
    render json: message, status: :ok
  end
end