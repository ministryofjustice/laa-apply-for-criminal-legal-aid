require 'rails_helper'

describe ProviderDataApi::ActiveOfficeCodesFilter do
  let(:office_codes) { %w[1A2B3C 2B3C4E] }

  describe '.call' do
    subject(:filtered_office_codes) { described_class.call(office_codes) }

    before do
      stub_request(:head, 'https://pda.example.com/provider-offices/2B3C4E/schedules')
        .to_return(status: 200)
      stub_request(:head, 'https://pda.example.com/provider-offices/1A2B3C/schedules')
        .to_return(status:)
    end

    let(:status) { 200 }

    describe 'when an office is active' do
      let(:status) { 200 }

      it 'keeps the office code in the list' do
        expect(filtered_office_codes).to eq office_codes
      end
    end

    describe 'when an office is inactive' do
      let(:status) { 204 }

      it 'office_code is filtered from the list' do
        expect(filtered_office_codes).to eq ['2B3C4E']
      end
    end

    describe 'when an office is not found' do
      let(:status) { 404 }

      it 'office_code is filtered from the list' do
        expect(filtered_office_codes).to eq ['2B3C4E']
      end
    end

    describe 'when the Provider Data API returns a server error' do
      let(:status) { 500 }

      it 'raises a ServerError' do
        expect { filtered_office_codes }.to raise_error Faraday::ServerError
      end
    end

    describe 'when the Provider Data API returns a ForbiddenError error' do
      let(:status) { 403 }

      it 'raises a ProviderDataApi::ForbiddenError' do
        expect { filtered_office_codes }.to raise_error Faraday::ForbiddenError
      end
    end

    describe 'when the Provider Data API returns a conflict error' do
      let(:url) { 'https://pda.example.com/provider-offices/C1C83H/schedules' }
      let(:office_codes) { super() << 'C1C83H' }

      context 'when API responds successfully after two attempts' do
        before do
          stub_request(:head, url).to_return(
            { status: 409 },
            { status: 200 }
          )
        end

        it 'keeps the office code in the list after retry' do
          expect(filtered_office_codes).to eq %w[1A2B3C 2B3C4E C1C83H]

          expect(WebMock).to have_requested(:head, url).times(2)
        end
      end

      context 'when API does not respond successfully' do
        before do
          stub_request(:head, url).to_return(
            { status: 409 },
            { status: 409 },
            { status: 409 }
          )
        end

        it 'raise a conflict error' do
          expect { filtered_office_codes }.to raise_error(Faraday::ConflictError)

          expect(WebMock).to have_requested(:head, url).times(3)
        end
      end
    end

    describe 'when `area_of_law` is specified' do
      it 'scopes PDA request by the area of law' do
        stub_request(:head, 'https://pda.example.com/provider-offices/9B3C4E/schedules?areaOfLaw=CIVIL%20FUNDING')
          .to_return(status: 200)

        described_class.call(['9B3C4E'], area_of_law: 'CIVIL FUNDING')
      end

      it 'returns an error if not a ProviderDataApi::Types::AreaOfLaw' do
        expect { described_class.call(['9B3C4E'], area_of_law: 'CIVIL BUNDING') }
          .to raise_error Dry::Types::ConstraintError
      end
    end
  end
end
