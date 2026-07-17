require 'rails_helper'

RSpec.describe Evidence::Rules::LostJobNotInCustody do
  subject { described_class.new(crime_application) }

  include_context 'serializable application'

  let(:case_type) { CaseType::EITHER_WAY }

  before do
    income.employment_status = ['not_working']
    income.lost_job_in_custody = 'no'
    income.ended_employment_within_three_months = 'yes'
  end

  it { expect(described_class.key).to eq :lost_job_34 }
  it { expect(described_class.group).to eq :none }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when all conditions are met' do
      it { expect(subject).to be true }
    end

    context 'when income is nil' do
      before do
        crime_application.income = nil
      end

      it { expect(subject).to be false }
    end

    context 'when employment_status is not not_working' do
      before do
        income.employment_status = ['employed']
      end

      it { expect(subject).to be false }
    end

    context 'when ended_employment_within_three_months is no' do
      before do
        income.ended_employment_within_three_months = 'no'
      end

      it { expect(subject).to be false }
    end

    context 'when lost_job_in_custody is yes' do
      before do
        income.lost_job_in_custody = 'yes'
      end

      it { expect(subject).to be false }
    end

    context 'when lost_job_in_custody is nil' do
      before do
        income.lost_job_in_custody = nil
      end

      it { expect(subject).to be false }
    end
  end

  describe '.partner' do
    subject { described_class.new(crime_application).partner_predicate }

    it { expect(subject).to be false }
  end

  describe '.other' do
    subject { described_class.new(crime_application).other_predicate }

    it { expect(subject).to be false }
  end

  describe '#to_h' do
    let(:expected_hash) do
      {
        id: 'LostJobNotInCustody',
        group: :none,
        ruleset: nil,
        key: :lost_job_34,
        run: {
          client: {
            result: true,
            prompt: ['their P45 or a letter from their former employer'],
          },
          partner: {
            result: false,
            prompt: [],
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
