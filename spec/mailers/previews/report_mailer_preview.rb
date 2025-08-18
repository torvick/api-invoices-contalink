class ReportMailerPreview < ActionMailer::Preview
  def top_selling_days
    ReportMailer.top_selling_days
  end
end
