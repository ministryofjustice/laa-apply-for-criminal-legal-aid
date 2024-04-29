require 'rails_helper'

RSpec.describe Evidence::Rules::LostJob do
  subject { described_class.new(crime_application) }

  let(:crime_application) do
    CrimeApplication.create!(
      income:,
      case:
    )
  end

  let(:income) { Income.new }
  let(:case) { Case.new }

  it { expect(described_class.key).to eq :lost_job_33 }
  it { expect(described_class.group).to eq :none }
  it { expect(described_class.archived).to be false }
  it { expect(described_class.active?).to be true }

  describe 'REMANDED_MONTHS_THRESHOLD' do
    it 'is 3 months' do
      expect(described_class::REMANDED_MONTHS_THRESHOLD).to eq 3
    end
  end

  describe '.client' do
    subject { described_class.new(crime_application).client_predicate }

    context 'when they lost job in custody, with date stamp and remanded within 3 months' do
      before do
        crime_application.income.lost_job_in_custody = 'yes'
        crime_application.date_stamp = DateTime.new(2024, 1, 14, 13, 23, 55)
        crime_application.case.date_client_remanded = Date.new(2024, 1, 1)
        now = Time.zone.local(2024, 4, 14, 13, 23, 55)

        travel_to now
      end

      it { expect(subject).to be true }
    end

    context 'when they lost job in custody, without date stamp and remanded within 3 months and on threshold' do
      before do
        crime_application.income.lost_job_in_custody = 'yes'
        crime_application.date_stamp = nil
        crime_application.case.date_client_remanded = Date.new(2024, 1, 1)
        now = Time.zone.local(2024, 4, 2, 13, 23, 55) # TODO: Seems to allow 1 extra day?

        travel_to now
      end

      it { expect(subject).to be true }
    end

    context 'when they lost job in custody, with date stamp and not in threshold' do
      before do
        crime_application.income.lost_job_in_custody = 'yes'
        crime_application.date_stamp = DateTime.new(2024, 1, 14, 13, 23, 55)
        crime_application.case.date_client_remanded = Date.new(2023, 10, 13)
        now = Time.zone.local(2024, 4, 14, 13, 23, 55)

        travel_to now
      end

      it { expect(subject).to be false }
    end

    context 'when income is nil' do
      let(:income) { nil }

      it { expect(subject).to be false }
    end

    context 'when case is nil' do
      let(:case) { nil }

      it { expect(subject).to be false }
    end

    context 'when date_client_remanded is nil' do
      before do
        crime_application.case.date_client_remanded = nil
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
    before do
      crime_application.income.lost_job_in_custody = 'yes'
      crime_application.case.date_client_remanded = 3.months.ago
    end

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
