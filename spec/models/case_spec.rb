require 'rails_helper'

RSpec.describe Case, type: :model do
  subject(:kase) { described_class.new(attributes) }

  let(:attributes) { {} }

  let(:case_attributes) do
    {
      crime_application: CrimeApplication.new,
      hearing_court_name: 'court name',
      hearing_date: Time.zone.today,
      is_first_court_hearing: nil,
      first_court_hearing_name: nil,
      has_case_concluded: nil,
      date_case_concluded: nil,
      is_client_remanded: nil,
      date_client_remanded: nil,
      is_preorder_work_claimed: nil,
      preorder_work_date: nil,
      preorder_work_details: nil
    }
  end

  describe 'validations' do
    let(:answers_validator) { double('answers_validator') }

    before do
      allow(CaseDetails::AnswersValidator).to receive(:new).with(kase).and_return(answers_validator)
    end

    describe 'valid?(:submission)' do
      it 'validates answers' do
        expect(answers_validator).to receive(:validate)

        kase.valid?(:submission)
      end
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

  describe '#complete?' do
    context 'when case is complete' do
      it 'returns true' do
        expect(kase).to receive(:valid?).with(:submission).and_return(true)
        expect(kase.complete?).to be true
      end
    end

    context 'when case is incomplete' do
      it 'returns false' do
        expect(kase).to receive(:valid?).with(:submission).and_return(false)
        expect(kase.complete?).to be false
      end
    end
  end

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
end
