require 'rails_helper'

RSpec.describe Providers::GetActiveOffice do
  describe '.call' do
    subject(:result) { described_class.call(office_code) }

    let(:office_code) { 'ABC123' }
    let(:translated_office) { double('Office', active?: true) }

    before do
      allow(ProviderDataApi::GetOfficeSchedules).to receive(:call)
        .with(office_code, area_of_law: 'CRIME LOWER')
        .and_return(:raw_schedule_data)

      allow(Providers::SchedulesToOfficeTranslator).to receive(:translate)
        .with(:raw_schedule_data)
        .and_return(translated_office)
    end

    context 'when the office is active' do
      it 'returns the office' do
        expect(result).to eq(translated_office)
      end
    end

    context 'when the office is inactive' do
      let(:translated_office) { double('Office', active?: false) }

      it 'raises Errors::OfficeNotFound' do
        expect {
          described_class.call(office_code)
        }.to raise_error(Errors::OfficeNotFound)
      end
    end

    context 'when ProviderDataApi::RecordNotFound is raised' do
      before do
        allow(ProviderDataApi::GetOfficeSchedules).to receive(:call)
          .and_raise(ProviderDataApi::RecordNotFound)
      end

      it 'raises Errors::OfficeNotFound' do
        expect {
          described_class.call(office_code)
        }.to raise_error(Errors::OfficeNotFound)
      end
    end
  end
end
