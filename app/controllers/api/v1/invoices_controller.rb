class Api::V1::InvoicesController < ApplicationController
  ALLOWED_SORTS    = %w[id invoice_date invoice_number total status].freeze
  DEFAULT_SORT_BY  = 'invoice_date'.freeze
  DEFAULT_SORT_DIR = :asc

  before_action :normalize_and_validate!

  def index
    invoices = Invoice
             .between_dates(@start_date, @end_date)
             .by_invoice_number(query_params[:invoice_number])
             .by_status(query_params[:status])
             .order(@sort_by => @sort_dir, id: :asc)
             .paginate(page: @page, per_page: @per_page)

    render_success(
      data: { invoices: invoices },
      meta: {
        count: invoices.total_entries,
        page: invoices.current_page,
        per_page: invoices.per_page,
        total_pages: invoices.total_pages,
        sort_by: @sort_by,
        sort_dir: @sort_dir
      }
    )
  end

  private

  def query_params
    params.permit(:start_date, :end_date, :invoice_number, :status, :sort_by, :sort_dir, :page, :per_page)
  end

  def normalize_and_validate!
    @start_date = Date.iso8601(params.require(:start_date))
    @end_date   = Date.iso8601(params.require(:end_date))
    raise ArgumentError, "end_before_start" if @end_date < @start_date

    @sort_by, @sort_dir = sort_params
    @page, @per_page    = pagination_params
  end

  def sort_params
    by  = query_params[:sort_by].to_s
    dir = query_params[:sort_dir].to_s.downcase
    by  = DEFAULT_SORT_BY unless ALLOWED_SORTS.include?(by)
    dir = %w[asc desc].include?(dir) ? dir.to_sym : DEFAULT_SORT_DIR
    [by, dir]
  end
end
