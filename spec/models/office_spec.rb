require 'rails_helper'

RSpec.describe Office do
  before do
    allow(FeatureFlags).to receive(:provider_data_api) {
      instance_double(FeatureFlags::EnabledFeature, enabled?: provider_data_api_enabled)
    }
  end

  describe '.find' do
    let(:office_code) { 'ABC123' }
    let(:provider_data_api_enabled) { true }

    context 'when office is found via provider API' do
      before do
        allow(Providers::GetActiveOffice).to receive(:call).with(office_code).and_return(
          described_class.new(
            office_code: office_code,
            name: 'Test Office',
            active?: true,
            contingent_liability?: false
          )
        )
      end

      it 'returns the office from provider API' do
        office = described_class.find(office_code)
        expect(office).to be_a(described_class)
        expect(office.office_code).to eq(office_code)
      end
    end

    context 'when office is not found via provider API' do
      before do
        allow(Providers::GetActiveOffice).to receive(:call).with(office_code).and_raise(
          Errors::OfficeNotFound
        )
      end

      it 'returns nil' do
        expect(described_class.find(office_code)).to be_nil
      end
    end
  end

  describe '.find!' do
    subject(:found_office) { described_class.find!(office_code) }

    let(:office_code) { 'XYZ789' }

    context 'when provider_data_api feature flag is enabled' do
      let(:provider_data_api_enabled) { true }

      let(:office) do
        described_class.new(
          office_code: office_code,
          name: 'Provider Office',
          active?: true,
          contingent_liability?: false
        )
      end

      before do
        allow(Providers::GetActiveOffice).to receive(:call).with(office_code).and_return(office)
      end

      it { is_expected.to be office }
    end

    context 'when provider_data_api feature flag is disabled' do
      let(:provider_data_api_enabled) { false }

      it 'returns a static office with default attributes' do
        expect(found_office.office_code).to eq(office_code)
        expect(found_office.name).to eq(office_code)
        expect(found_office.active?).to be true
        expect(found_office.contingent_liability?).to be false
      end
    end
  end
end
