require 'rails_helper'

RSpec.describe BusinessHoursMiddleware do
  subject(:middleware) { described_class.new(app) }

  let(:app) { ->(_env) { [200, { 'Content-Type' => 'text/html' }, ['OK']] } }
  let(:env) { Rack::MockRequest.env_for('/') }

  describe '#call' do
    context 'when today is a bank holiday' do
      before do
        allow(Govuk::BankHolidays).to receive(:call).and_return([Date.current])
      end

      it 'returns a 503 status' do
        status, = middleware.call(env)
        expect(status).to eq(503)
      end

      it 'returns an HTML content type' do
        _, headers, = middleware.call(env)
        expect(headers['Content-Type']).to eq('text/html; charset=utf-8')
      end

      it 'returns the bank holiday HTML page' do
        _, _, body = middleware.call(env)
        expect(body.first).to include('Sorry, the service is unavailable')
      end

      it 'does not call the downstream app' do
        expect(app).not_to receive(:call)
        middleware.call(env)
      end
    end

    context 'when today is not a bank holiday and within business hours' do
      before do
        allow(Govuk::BankHolidays).to receive(:call).and_return([Date.current + 1])
        travel_to Time.find_zone('London').parse('12:00')
      end

      it 'passes the request to the downstream app' do
        status, = middleware.call(env)
        expect(status).to eq(200)
      end
    end

    context 'when the current time is within business hours' do
      before do
        allow(Govuk::BankHolidays).to receive(:call).and_return([])
      end

      it 'passes the request at the opening boundary' do
        travel_to Time.find_zone('London').parse('07:00') do
          status, = middleware.call(env)
          expect(status).to eq(200)
        end
      end

      it 'passes the request in the middle of the day' do
        travel_to Time.find_zone('London').parse('12:00') do
          status, = middleware.call(env)
          expect(status).to eq(200)
        end
      end

      it 'passes the request just before closing' do
        travel_to Time.find_zone('London').parse('21:29') do
          status, = middleware.call(env)
          expect(status).to eq(200)
        end
      end
    end

    context 'when the current time is outside business hours' do
      before do
        allow(Govuk::BankHolidays).to receive(:call).and_return([])
      end

      it 'returns a 503 before opening time' do
        travel_to Time.find_zone('London').parse('06:59') do
          status, = middleware.call(env)
          expect(status).to eq(503)
        end
      end

      it 'returns a 503 at the closing boundary' do
        travel_to Time.find_zone('London').parse('21:30') do
          status, = middleware.call(env)
          expect(status).to eq(503)
        end
      end

      it 'returns a 503 after closing time' do
        travel_to Time.find_zone('London').parse('22:00') do
          status, = middleware.call(env)
          expect(status).to eq(503)
        end
      end

      it 'does not call the downstream app' do
        travel_to Time.find_zone('London').parse('22:00') do
          expect(app).not_to receive(:call)
          middleware.call(env)
        end
      end
    end

    context 'when the path is a bypass path' do
      before do
        allow(Govuk::BankHolidays).to receive(:call).and_return([Date.current])
      end

      BusinessHoursMiddleware::BYPASS_PATHS.each do |path|
        it "passes through requests to #{path}" do
          bypass_env = Rack::MockRequest.env_for(path)
          status, = middleware.call(bypass_env)
          expect(status).to eq(200)
        end
      end
    end
  end
end
