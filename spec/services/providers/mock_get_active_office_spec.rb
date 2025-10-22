require 'rails_helper'

RSpec.describe Providers::MockGetActiveOffice do
  describe '.call' do
    subject(:result) { described_class.call(office_code) }

    let(:translated_office) { double('Office', active?: true) }

    context 'when the office is active' do
      let(:office_code) { '1A123B' }

      it 'returns the office' do
        expect(result.office_code).to eq office_code
        expect(result.active?).to be true
        expect(result.contingent_liability?).to be false
      end
    end

    context 'when the office is inactive' do
      let(:office_code) { 'ZYX123' }

      it 'raises Errors::OfficeNotFound' do
        expect { result }.to raise_error(Errors::OfficeNotFound)
      end
    end

    context 'when the office is in contingent_liability' do
      let(:office_code) { '4C567D' }

      it 'returns the office' do
        expect(result.office_code).to eq office_code
        expect(result.contingent_liability?).to be true
      end
    end
  end
end
