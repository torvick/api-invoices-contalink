class Invoice < ApplicationRecord

  scope :between_dates, ->(start_date, end_date) {
    where(invoice_date: start_date..end_date)
  }

  scope :by_status, ->(status) {
    status.blank? ? all : where(status: status)
  }

  scope :by_invoice_number, ->(number) do
    next all if number.blank?

    term = ActiveRecord::Base.sanitize_sql_like(number.to_s.strip)
    where("invoice_number ILIKE ?", "%#{term}%")
  end
end
