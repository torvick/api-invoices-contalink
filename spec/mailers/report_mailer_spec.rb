require "rails_helper"

RSpec.describe ReportMailer, type: :mailer do
  let(:rows) do
    [
      { top: 1, day: Date.new(2025, 8, 10), amount: 500.00 },
      { top: 2, day: Date.new(2025, 8,  9), amount: 400.00 }
    ]
  end

  subject(:mail) { described_class.top_selling_days(to: ["test@example.com"], rows: rows) }

  it "renderiza encabezados" do
    expect(mail.subject).to include("Top 10")
    expect(mail.to).to eq(["test@example.com"])
    expect(mail.from).to be_present
  end

  it "renderiza la parte HTML" do
    html = mail.html_part ? mail.html_part.body.decoded : mail.body.decoded
    expect(html).to include("<h2>Top 10</h2>")
    expect(html).to include("<th>Top</th>")
    expect(html).to include("<th>Dia</th>")
    expect(html).to include("<th>Venta total</th>")
    expect(html).to include(rows.first[:day].to_s)
    expect(html).to include(sprintf("%.2f", rows.first[:amount]))
  end

  it "renderiza la parte de texto" do
    text = mail.text_part ? mail.text_part.body.decoded : mail.body.decoded
    expect(text).to include("Top 10")
    expect(text).to include("Top: 1")
    expect(text).to include("2025-08-10")
  end

  it "se puede entregar" do
    ActionMailer::Base.deliveries.clear
    expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
