class ApplicationController < ActionController::API

  protected
  def except_data(data, parameters = [:password_digest, :_id])
    return data.as_json({except: parameters}).reverse_merge({id: data._id.to_s})
  end

  def set_paging
    @limit = params[:limit] ? params[:limit].to_i : 10
    @page = params[:page] ? params[:page].to_i : 1
    @offset = @page == 1 ? 0 : (@limit.to_i * @page.to_i) - @limit.to_i
  end

  def param_to_search(param)
    return CGI.unescape(param.to_s)
  end
end
