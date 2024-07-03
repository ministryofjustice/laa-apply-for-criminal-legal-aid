require 'rails_helper'

RSpec.describe Evidence::Rules::SelfEmployed do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      income:,
    )
  end

  let(:income) { Income.new }
  let(:include_partner?) { true }

  before do
    allow(MeansStatus).to receive(:include_partner?).and_return(include_partner?)
  end

  it { expect(described_class.key).to eq :income_selfemployed_3 }
  it { expect(described_class.group).to eq :income }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when self-employed' do
      let(:employment_status) { 'self_employed' }

      it 'is false' do
        crime_application = CrimeApplication.new(income: Income.new(employment_status: [employment_status]))

        expect(described_class.new(crime_application).client_predicate).to be true
      end
    end

    context 'when employed or not working' do
      it 'is false' do
        %w[not_working employed].each do |employment_status|
          crime_application = CrimeApplication.new(income: Income.new(employment_status: [employment_status]))

          expect(described_class.new(crime_application).client_predicate).to be false
        end
      end
    end

    context 'when there is no income' do
      let(:income) { nil }

      it { is_expected.to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    context 'when self employed' do
      let(:income) { Income.new(partner_employment_status: [EmploymentStatus::SELF_EMPLOYED]) }

      it { is_expected.to be true }
    end

    context 'when employed or not working' do
      let(:income) {
        Income.new(partner_employment_status: [EmploymentStatus::NOT_WORKING,
                                               EmploymentStatus::EMPLOYED])
      }

      it { is_expected.to be false }
    end

    context 'when there is no employment status' do
      let(:income) { Income.new(partner_employment_status: nil) }

      it { is_expected.to be false }
    end

    context 'when there is no income' do
      let(:income) { nil }

      it { is_expected.to be false }
    end
  end

  describe '.other' do
    it { expect(subject.other_predicate).to be false }
  end

  describe '#to_h' do
    let(:income) do
      Income.new(employment_status: [EmploymentStatus::SELF_EMPLOYED],
                 partner_employment_status: [EmploymentStatus::SELF_EMPLOYED])
    end

    let(:expected_hash) do
      {
        id: 'SelfEmployed',
        group: :income,
        ruleset: nil,
        key: :income_selfemployed_3,
        run: {
          client: {
            result: true,
            prompt: ['complete financial accounts, tax return, bank statements, cash book or other business records'],
          },
          partner: {
            result: true,
            prompt: ['complete financial accounts, tax return, bank statements, cash book or other business records'],
          },
          other: {
            result: false,
            prompt: [],
          },
        }
      }
    end

    it { expect(subject.to_h).to eq expected_hash }
  end
end
