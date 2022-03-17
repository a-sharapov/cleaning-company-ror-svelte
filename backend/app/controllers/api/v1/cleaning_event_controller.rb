class Api::V1::CleaningEventController < ApplicationController
  before_action :set_paging, only: [:index] 
  before_action :set_events_search_query, only: [:index] 
  before_action :get_tokens, only: [:update, :destroy] 
  before_action :get_event, only: [:show, :update, :destroy] 

  def index
    begin
      events = CleaningEvent.all_of(@search_query).limit(@limit).offset(@offset).asc(:id)
      escape_with!(:events, :not_found, :ok) unless events.any?
      data = except_all(events)
      records = events.count
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
      escape_with!(:events, :not_exist, :ok) unless @event
      render_data(@event)
    rescue ApiError => e
      render_api_error(e)
    end 
  end
  
  def new
    begin
      user = prepare_user!
      escape_with!(:events, :already_exist, :ok) if Review.find_by(customer: user.login)
      event = CleaningEvent.new(event_parameters)
      event.customer = user ? user.login : "Anonymous"
      company = CompanyProfile.find_by(company_name: event_parameters[:company_name])
      escape_with!(:profiles, :not_exist, :ok, review.errors.full_messages) unless company
      event.company_profile = company
      escape_with!(:events, :already_exist, :ok) if CleaningEvent.find_by(customer: user.login, company_profile: company)
      escape_with!(:api, :invalid_request, :ok, event.errors.full_messages) unless event.valid? && event.save()
      if event_parameters[:attachments].present?
        event_parameters[:attachments].map { |attachment_data| 
          attachment = Attachment.new(attachment_data)
          attachment.cleaning_event = event
          escape_with!(:api, :invalid_request, :unprocessable_entity, attachment.errors.full_messages) unless attachment.save()
        }
      end
      render_data(event)
    rescue ApiError => e
      render_api_error(e)
    end
  end
  
  def update  
    begin
      user = prepare_user!
      escape_with!(:events, :not_exist, :ok) unless @event
      escape_with!(:api, :invalid_request, :ok, @event.errors.full_messages) unless @event.valid? && @event.update(event_parameters)
      if event_parameters[:attachments].present?
        event_parameters[:attachments].map { |attachment_data| 
          attachment = Attachment.find_by(cleaning_event: @event)
          escape_with!(:attachments, :not_found, :ok) unless attachment
          escape_with!(:api, :invalid_request, :ok, attachment.errors.full_messages) unless attachment.update(attachment_data)
        }
      end
      render_data(@event)
    rescue ApiError => e
      render_api_error(e)
    end
  end
  
  def destroy
    begin
      user = prepare_user!
      escape_with!(:events, :not_exist, :ok) unless @event
      escape_with!(:events, :not_remove, :ok) unless @event.destroy
      render json: {message: ApiError::MESSAGES[:events][:deleted]}, status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end

  private
  def event_parameters 
    params.permit(
      :customer,
      :type,
      :description,
      :schedule,
      :is_regular,
      :planed_at,
      :services,
      :attachments,
      address: [
        :zip, 
        :country, 
        :city, 
        :state, 
        :street
      ],
      assets: {
        :standard,
        :large,
        :restroom,
        :invoice
      }
    )
  end

  def get_event
    @slug = params[:slug]
    @event = CleaningEvent.find_by(slug: @slug)
  end

  def set_events_search_query
    @search_query = {}

    case true
      when !params[:company_name].nil?
        @search_query[:company_name] = /.*#{param_to_search(params[:company_name])}.*/
      when !params[:customer].nil?
        @search_query[:customer] = /.*#{param_to_search(params[:customer])}.*/
      when !params[:type].nil?
        @search_query[:type] = param_to_search(params[:type])
      when !params[:planed_at].nil?
        @search_query[:planed_at] = param_to_search(params[:planed_at])
      when !params[:is_regular].nil?
        @search_query[:is_regular] = param_to_search(params[:is_regular])
    end
  end
end