require "rails_helper"

RSpec.describe UserBanMailer, type: :mailer do
  describe "ban_notification" do
    let(:mail) { UserBanMailer.ban_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("Ban notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "unban_notification" do
    let(:mail) { UserBanMailer.unban_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("Unban notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
