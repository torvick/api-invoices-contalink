class ApplicationController < ActionController::API
  include ApiResponder
  include ErrorHandler

  DEFAULT_PER_PAGE = 50
  MAX_PER_PAGE     = 200

  def pagination_params
    page     = query_params[:page].to_i
    per_page = query_params[:per_page].to_i
    page     = 1 if page < 1
    per_page = DEFAULT_PER_PAGE unless per_page.between?(1, MAX_PER_PAGE)
    [page, per_page]
  end
end
