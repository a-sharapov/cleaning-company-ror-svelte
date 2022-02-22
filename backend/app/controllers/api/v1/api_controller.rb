class Api::V1::ApiController < ApplicationController

  API_MESSAGES = {
    service_name: ENV["SERVICE_NAME"],
    working: "API server currently working...",
    version: "1.0"
  }
  
  def index
    render :template => "api-hello", :locals => {:content => API_MESSAGES}
  end

  def endpoints 
    message = {
      "name": API_MESSAGES[:service_name],
      "api_version": API_MESSAGES[:version],
      "available_endpoints": [
        "users",
        "auth",
        "companies",
        "assets",
        "manager"
      ]
    }
    render json: message, status: :ok
  end
end