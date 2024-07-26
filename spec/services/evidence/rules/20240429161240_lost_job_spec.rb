require 'rails_helper'

RSpec.describe Evidence::Rules::LostJob do
  subject { described_class.new(crime_application) }

  include_context 'serializable application'

  let(:date_job_lost) { nil }

  before do
    income.employment_status = ['not_working']
    income.lost_job_in_custody = 'yes'
    income.ended_employment_within_three_months = 'yes'
    income.date_job_lost = date_job_lost
  end

  it { expect(described_class.key).to eq :lost_job_33 }
  it { expect(described_class.group).to eq :none }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe 'LOST_JOB_THRESHOLD' do
    it 'is 3 months duration' do
      expect(described_class::LOST_JOB_THRESHOLD).to eq 3.months
    end
  end

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when they lost job' do
      before do
        crime_application.date_stamp = date_stamp

        travel_to now
      end

      context 'with date stamp and lost job within 3 months' do
        let(:now) { Time.zone.local(2024, 4, 14, 13, 23, 55) }
        let(:date_stamp) { DateTime.new(2024, 1, 14, 13, 23, 55) }
        let(:date_job_lost) { Date.new(2024, 1, 1) }

        it { expect(subject).to be true }
      end

      context 'without date stamp and lost job within 3 months and on threshold' do
        let(:now) { Time.zone.local(2024, 3, 31, 23, 59, 59) }
        let(:date_stamp) { nil }
        let(:date_job_lost) { Date.new(2024, 1, 1) }

        it { expect(subject).to be true }
      end

      context 'without date stamp and lost job within 3 months just after threshold' do
        let(:now) { Time.zone.local(2024, 4, 1, 0, 0, 59) }
        let(:date_stamp) { nil }
        let(:date_job_lost) { Date.new(2024, 1, 1) }

        it { expect(subject).to be false }
      end

      context 'with date stamp and not in threshold' do
        let(:now) { Time.zone.local(2024, 4, 14, 13, 23, 55) }
        let(:date_stamp) { DateTime.new(2024, 1, 14, 13, 23, 55) }
        let(:date_job_lost) { Date.new(2023, 10, 13) }

        it { expect(subject).to be false }
      end
    end

    context 'when income is nil' do
      before do
        crime_application.income = nil
      end

      it { expect(subject).to be false }
    end

    context 'when date_job_lost is nil' do
      before do
        crime_application.income.date_job_lost = nil
      end

      it { expect(subject).to be false }
    end

    context 'when client has not lost job' do
      before do
        income.lost_job_in_custody = 'no'
        crime_application.income.date_job_lost = 2.months.ago
      end

      it { expect(subject).to be false }
    end

    context 'when client said they did not lose job within 3 months' do
      before do
        income.ended_employment_within_three_months = 'no'
        crime_application.income.date_job_lost = 2.months.ago
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
    let(:now) { Time.zone.now }
    let(:date_job_lost) { 1.month.ago }

    let(:expected_hash) do
      {
        id: 'LostJob',
        group: :none,
        ruleset: nil,
        key: :lost_job_33,
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
