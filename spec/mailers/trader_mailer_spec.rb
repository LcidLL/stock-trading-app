require "rails_helper"

RSpec.describe TraderMailer, type: :mailer do
  describe "approval_notification" do
    let(:mail) { TraderMailer.approval_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("Approval notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "rejection_notification" do
    let(:mail) { TraderMailer.rejection_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("Rejection notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
