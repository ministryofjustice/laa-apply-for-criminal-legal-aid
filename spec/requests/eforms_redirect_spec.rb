require "rails_helper"

RSpec.describe "eForms redirect" do
  describe 'eForms redirect page' do
    before :all do
      # sets up a valid session
      get '/steps/client/has_partner'

      # page actually under test
      get '/steps/client/nino_exit'
    end

    it "returns the correct with success" do
      expect(response).to have_http_status(:success)
    end

    it "returns the correct redirect link to eForms" do
      expect(response.body).to include("https://portal.legalservices.gov.uk")
    end

    it "returns the correct copy" do
      copy = [
        "Use eForms for this application",
        "You cannot use this service if your client:",
        "has a partner",
        "does not have a National Insurance number",
        "does not receive a passporting benefit based on DWP records, including Universal Credits",
        "is employed, including self-employed, business partner, company director or shareholder"
      ]

      copy.each do |copy_item|
        expect(response.body).to include(copy_item)
      end
    end
  end
end
