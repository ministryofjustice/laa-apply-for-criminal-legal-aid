require 'rails_helper'

RSpec.describe IncomePresenter do
  let(:income) do
    instance_double(
      Income,
      employment_status:,
      partner_employment_status:,
    )
  end

  let(:employment_status) { %w[employed self_employed] }
  let(:partner_employment_status) { %w[employed self_employed] }

  describe '#employment_status_text' do
    subject { described_class.present(income).employment_status_text }

    it { is_expected.to eq('employed_and_self_employed') }

    context 'when employed' do
      let(:employment_status) { %w[employed] }

      it { is_expected.to eq('employed') }
    end

    context 'when empty' do
      let(:employment_status) { [] }

      it { is_expected.to eq('') }
    end
  end

  describe '#partner_employment_status_text' do
    subject { described_class.present(income).partner_employment_status_text }

    it { is_expected.to eq('employed_and_self_employed') }

    context 'when self_employed' do
      let(:partner_employment_status) { %w[self_employed] }

      it { is_expected.to eq('self_employed') }
    end

    context 'when empty' do
      let(:partner_employment_status) { [] }

      it { is_expected.to eq('') }
    end
  end
end
