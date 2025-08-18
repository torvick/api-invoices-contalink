require "rails_helper"

RSpec.describe TopSellingDaysEmailJob, type: :job do
  Row = Struct.new(:day, :amount)
  let(:rel) { double("AR::Relation") }
  let(:ar_rows) do
    [
      Row.new(Date.new(2025, 8, 10), 500.0),
      Row.new(Date.new(2025, 8,  9), 400.0)
    ]
  end

  let(:expected_rows) do
    ar_rows.each_with_index.map { |r, idx| { top: idx + 1, day: r.day, amount: r.amount.to_f } }
  end

  before do
    allow(Rails.application.credentials).to receive(:dig).and_return(nil)
    allow(Rails.application.credentials).to receive(:dig).with(:smtp, :from).and_return("no-reply@example.com")
  end

  it "construye el reporte y envía el correo a los destinatarios" do
    allow(Rails.application.credentials).to receive(:dig)
      .with(:smtp, :recipients).and_return("a@example.com, b@example.com")
    allow(Invoice).to receive(:select)
      .with("DATE(invoice_date) AS day, SUM(total)::float AS amount").and_return(rel)
    allow(rel).to receive(:group).with("day").and_return(rel)
    allow(rel).to receive(:order).with("amount DESC").and_return(rel)
    allow(rel).to receive(:limit).with(10).and_return(rel)
    allow(rel).to receive(:each_with_index).and_return(ar_rows.each_with_index)
    mail_double = double(deliver_now: true)
    expect(ReportMailer)
      .to receive(:top_selling_days)
      .with(to: array_including("a@example.com", "b@example.com"), rows: expected_rows)
      .and_return(mail_double)

    described_class.perform_now
  end

  it "no hace nada si no hay recipients en credentials" do
    allow(Rails.application.credentials).to receive(:dig).with(:smtp, :recipients).and_return(nil)

    expect(Invoice).not_to receive(:select)
    expect(ReportMailer).not_to receive(:top_selling_days)

    described_class.perform_now
  end
end
º