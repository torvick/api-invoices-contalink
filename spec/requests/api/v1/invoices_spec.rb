require "rails_helper"

RSpec.describe "GET /api/v1/invoices", type: :request do
  let(:start_date) { "2022-01-01" }
  let(:end_date)   { "2022-12-31" }

  it "Return 200 with wrapper data/meta" do
    get "/api/v1/invoices", params: { start_date:, end_date:, per_page: 50 }

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json["status"]).to eq("success")
    expect(json["data"]).to have_key("invoices")
    expect(json["data"]["invoices"]).to be_an(Array)

    expect(json["meta"]).to include("count", "page", "per_page", "total_pages", "sort_by", "sort_dir")
    expect(json["meta"]["count"]).to be_a(Integer)
    expect(json["meta"]["per_page"]).to eq(50)
  end

  it "Filters and response 200" do
    get "/api/v1/invoices", params: { start_date:, end_date:, status: "Cancelado", sort_by: "invoice_date", sort_dir: "asc", per_page: 10 }

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json["meta"]["per_page"]).to eq(10)
    expect(%w[asc desc]).to include(json["meta"]["sort_dir"])
  end

  it "fallback with sort_by is invalid" do
    get "/api/v1/invoices", params: { start_date:, end_date:, sort_by: "hack", sort_dir: "desc" }

    json = JSON.parse(response.body)
    expect(json["meta"]["sort_by"]).to eq("invoice_date") # default
    expect(json["meta"]["sort_dir"]).to satisfy { |v| %w[asc desc].include?(v) }
  end

  it "per_page out of range by default" do
    get "/api/v1/invoices", params: { start_date:, end_date:, per_page: 9_999 }

    json = JSON.parse(response.body)
    expect(json["meta"]["per_page"]).to eq(50) # DEFAULT_PER_PAGE
  end

  it "responds 400 if start_date is missing" do
    get "/api/v1/invoices", params: { end_date: }

    expect(response).to have_http_status(:bad_request)
    json = JSON.parse(response.body)
    expect(json["status"]).to eq("error")
    expect(json["error"]["code"]).to eq("missing_params")
    expect(json["error"]["message"]).to eq("start_date")
  end

  it "responds 422 if end_before_star" do
    get "/api/v1/invoices", params: { start_date: end_date, end_date: start_date }

    expect(response).to have_http_status(:unprocessable_content)
    json = JSON.parse(response.body)
    expect(json["error"]["code"]).to eq("invalid_params")
    expect(json["error"]["message"]).to eq("end_before_start")
  end

  it "responds 422 if invalid date" do
    get "/api/v1/invoices", params: { start_date: "2025-13-01", end_date: ""}

    expect(response).to have_http_status(:unprocessable_content)
    json = JSON.parse(response.body)
    expect(json["error"]["code"]).to eq("invalid_params")
  end
end
