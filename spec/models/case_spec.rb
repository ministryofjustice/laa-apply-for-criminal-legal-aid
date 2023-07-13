require 'rails_helper'

RSpec.describe Case, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) { {} }

  describe '#hearing_court' do
    let(:attributes) { { hearing_court_name: court_name } }

    context 'for a known court' do
      let(:court_name) { 'Croydon Crown Court' }

      it { expect(subject.hearing_court).not_to be_nil }
      it { expect(subject.hearing_court.name).to eq(court_name) }
    end

    context 'for an unknown court' do
      let(:court_name) { 'Foobar Court' }

      it { expect(subject.hearing_court).to be_nil }
    end

    context 'for a blank court' do
      let(:court_name) { '' }

      it { expect(subject.hearing_court).to be_nil }
    end
  end

  describe '`charges` relationship' do
    subject(:charges) do
      described_class.create(
        crime_application:
      ).charges
    end

    let(:crime_application) { CrimeApplication.create }

    it 'initialises a blank `offence_date` when building charges' do
      expect(
        charges.build.offence_dates
      ).to contain_exactly(kind_of(OffenceDate))
    end

    it 'initialises a blank `offence_date` when adding charges' do
      expect do
        charges << Charge.new
      end.to change(OffenceDate, :count).by(1)
    end

    it 'initialises a blank `offence_date` when creating charges' do
      expect do
        charges.create
      end.to change(OffenceDate, :count).by(1)
    end

    it 'has an association extension to return only complete charges' do
      charges << Charge.new
      expect(charges.complete).to be_empty
    end
  end
end
