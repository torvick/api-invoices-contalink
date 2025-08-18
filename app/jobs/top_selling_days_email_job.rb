class TopSellingDaysEmailJob < ApplicationJob
  queue_as :default

  def perform
    recipients = Rails.application.credentials.dig(:smtp, :recipients).to_s.split(",").map(&:strip).reject(&:blank?)
    return if recipients.empty?

    invoices = Invoice
                .select("DATE(invoice_date) AS day, SUM(total)::float AS amount")
                .group("day")
                .order("amount DESC")
                .limit(10)
                .each_with_index
                .map { |r, idx| { top: idx + 1, day: r.day, amount: r.amount.to_f } }

    ReportMailer.top_selling_days(to: recipients, rows: invoices).deliver_now
  end
end
