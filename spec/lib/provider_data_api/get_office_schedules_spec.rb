require 'rails_helper'

RSpec.describe ProviderDataApi::GetOfficeSchedules do
  subject(:service_call) { described_class.new(office_code:, area_of_law:, http_client:).call }

  let(:office_code) { '1A2B3C' }
  let(:area_of_law) { 'CRIME LOWER' }
  let(:http_client) { instance_double(Faraday::Connection) }

  before do
    ProviderDataApi::RequestMonitor.reset!
  end

  def expect_metric(outcome:, http_status:, error_class: 'none')
    labels = {
      outcome: outcome,
      operation: ProviderDataApi::RequestMonitor::OPERATION_GET_OFFICE_SCHEDULES,
      http_status: http_status,
      error_class: error_class,
    }
    expect(ProviderDataApi::RequestMonitor.snapshot).to include(labels => 1)
  end

  describe '#call' do
    context 'when the request succeeds' do
      let(:body) { JSON.parse(file_fixture('provider_data_api/public_defender_service.json').read) }
      let(:response) { instance_double(Faraday::Response, status: 200, body: body) }

      before do
        allow(http_client).to receive(:get).and_return(response)
      end

      it 'returns office schedules and records success metrics' do
        expect(service_call).to be_a(ProviderDataApi::OfficeSchedules)
        expect_metric(outcome: 'success', http_status: '200')
      end
    end

    context 'when the office is not returned by PDA' do
      let(:response) { instance_double(Faraday::Response, status: 204, body: nil) }

      before do
        allow(http_client).to receive(:get).and_return(response)
      end

      it 'raises record not found and records not_found metrics' do
        expect { service_call }.to raise_error(ProviderDataApi::RecordNotFound)
        expect_metric(outcome: 'not_found', http_status: '204')
      end
    end

    context 'when PDA is unavailable' do
      let(:connection_error) { Faraday::ConnectionFailed.new('execution expired') }

      before do
        allow(http_client).to receive(:get).and_raise(connection_error)
        allow(Rails.error).to receive(:report)
      end

      it 'reports the error and records failure metrics' do
        expect { service_call }.to raise_error(Faraday::ConnectionFailed)
        expect_error_reported
        expect_metric(outcome: 'failure', http_status: 'none', error_class: 'Faraday::ConnectionFailed')
      end

      def expect_error_reported
        expect(Rails.error).to have_received(:report).with(
          connection_error,
          hash_including(
            handled: true,
            severity: :error,
            context: hash_including(
              source: 'provider_data_api',
              operation: 'get_office_schedules',
              office_code: '1A2B3C'
            )
          )
        )
      end
    end
  end
end
