class Invoice < ApplicationRecord

  scope :between_dates, ->(start_date, end_date) {
    where(invoice_date: start_date..end_date)
  }

  scope :by_status, ->(status) {
    status.blank? ? all : where(status: status)
  }

  scope :by_invoice_number, ->(number) {
    number.blank? ? all : where(invoice_number: number)
  }
end
