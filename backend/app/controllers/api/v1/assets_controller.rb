class Api::V1::AssetsController < ApplicationController

  def index
    begin 
      assets = Assets.find_by(slug: params[:slug])
      escape_with!(:assets, :not_found, :ok) unless assets
      render json: except_data!(assets), status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def init
    begin
      key = init_parameters[:key]
      escape_with!(:auth, :unauthorized_access, :ok) unless key.eql?(ENV["SECRET_KEY"])
      escape_with!(:assets, :not_create, :ok) unless Assets.find_or_create_by(type: "Services", content: {
        elements: [
          "Стандартная уборка помещений", 
          "Генеральная уборка",
          "Уборка после ремонта и строительства",
          "Химчистка ковров",
          "Уборка офисов",
          "Химчистка мебели и покрытий",
          "Промышленная уборка",
          "Уборка бассейна"
        ]
      })
    
      escape_with!(:assets, :not_create, :ok) unless Assets.find_or_create_by(type: "Status", content: {
        new: "Новый",
        accepted: "Подтверждён",
        canceled: "Отменён",
      })
      render json: {message: "Assets created successfully"}, status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end

  private
  def init_parameters
    params.permit(:key)
  end
end
