class ReportMailer < ApplicationMailer

  def top_selling_days(to:, rows:)
    @sales = rows
    mail to: to, subject: "Top 10"
  end
end
