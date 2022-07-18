require "rails_helper"

RSpec.describe "Healthcheck endpoint" do
  let(:error_response)   { '{"healthcheck":"NOT OK"}' }
  let(:success_response) { '{"healthcheck":"OK"}' }

  describe 'healthchecks' do
    it "can report a success" do
      allow(ApplicationRecord.connection).to receive(:select_value)
        .with('SELECT 1')
        .and_return(1)

      get "/health"
      expect(response.body).to eq(success_response)
      expect(response).to have_http_status(200)
    end

    it "can report a failure" do
      allow(ApplicationRecord.connection).to receive(:select_value)
        .with('SELECT 1')
        .and_raise(StandardError)

      get "/health"
      expect(response.body).to eq(error_response)
      expect(response).to have_http_status(503)
    end
  end
end
