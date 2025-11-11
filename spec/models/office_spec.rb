require 'rails_helper'

RSpec.describe Office do
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

  describe '.find' do
    subject(:found_office) { described_class.find(office_code) }

    let(:office_code) { 'ABC123' }

    it { is_expected.to be office }

    context 'when office is not found via provider API' do
      before do
        allow(Providers::GetActiveOffice).to receive(:call).with(office_code).and_raise(
          Errors::OfficeNotFound
        )
      end

      it { is_expected.to be_nil }
    end
  end

  describe '.find!' do
    subject(:found_office) { described_class.find!(office_code) }

    let(:office_code) { 'XYZ789' }

    it { is_expected.to be office }

    context 'when office is not found via provider API' do
      before do
        allow(Providers::GetActiveOffice).to receive(:call).with(office_code).and_raise(
          Errors::OfficeNotFound
        )
      end

      it 'raises Errors::OfficeNotFound' do
        expect { found_office }.to(raise_error { Errors::OfficeNotFound })
      end
    end
  end
end
