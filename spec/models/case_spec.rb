require 'rails_helper'

RSpec.describe Case, type: :model do
  subject(:kase) { described_class.new(attributes) }

  let(:attributes) { {} }
  let(:hearing_date) { Time.zone.today }

  let(:case_attributes) do
    {
      crime_application: CrimeApplication.new,
      hearing_court_name: 'court name',
      hearing_date: hearing_date,
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

  describe '#hearing_date_within_range?' do
    context 'when latest hearing date is out of range' do
      let(:attributes) { { hearing_date: Date.parse('01-01-2036') } }

      it { expect(kase).not_to be_hearing_date_within_range }
    end

    context 'when earliest hearing date is out of range' do
      let(:attributes) { { hearing_date: Date.parse('31-12-2009') } }

      it { expect(kase).not_to be_hearing_date_within_range }
    end

    context 'when hearing date is within the range' do
      let(:attributes) { { hearing_date: Date.parse('01-01-2030') } }

      it { expect(kase).to be_hearing_date_within_range }
    end
  end

  # Appeal-specific logic tests - State combination scenarios
  describe 'appeal conditional logic' do
    describe 'Appeal with changes scenario' do
      let(:attributes) do
        {
          case_type: CaseType::APPEAL_TO_CROWN_COURT.to_s,
          appeal_original_app_submitted: 'yes',
          appeal_financial_circumstances_changed: 'yes',
          appeal_lodged_date: Date.parse('2024-01-15'),
          appeal_with_changes_details: 'Income increased by 10%'
        }
      end

      it 'includes appeal_lodged_date' do
        expect(kase.appeal_lodged_date).to eq(Date.parse('2024-01-15'))
      end

      it 'includes appeal_original_app_submitted' do
        expect(kase.appeal_original_app_submitted).to eq('yes')
      end

      it 'includes appeal_financial_circumstances_changed' do
        expect(kase.appeal_financial_circumstances_changed).to eq('yes')
      end

      it 'includes appeal_with_changes_details' do
        expect(kase.appeal_with_changes_details).to eq('Income increased by 10%')
      end

      it 'excludes reference numbers (not required when changes exist)' do
        expect(kase.appeal_maat_id).to be_nil
        expect(kase.appeal_usn).to be_nil
      end
    end

    describe 'Appeal without changes scenario (reference numbers required)' do
      let(:attributes) do
        {
          case_type: CaseType::APPEAL_TO_CROWN_COURT.to_s,
          appeal_original_app_submitted: 'yes',
          appeal_financial_circumstances_changed: 'no',
          appeal_lodged_date: Date.parse('2024-01-15'),
          appeal_maat_id: '1234567',
          appeal_usn: '87654321'
        }
      end

      it 'includes appeal_lodged_date' do
        expect(kase.appeal_lodged_date).to eq(Date.parse('2024-01-15'))
      end

      it 'includes appeal_original_app_submitted' do
        expect(kase.appeal_original_app_submitted).to eq('yes')
      end

      it 'includes appeal_financial_circumstances_changed as no' do
        expect(kase.appeal_financial_circumstances_changed).to eq('no')
      end

      it 'includes reference numbers when changes did not happen' do
        expect(kase.appeal_maat_id).to eq('1234567')
        expect(kase.appeal_usn).to eq('87654321')
      end
    end

    describe 'Appeal with original app not submitted' do
      let(:attributes) do
        {
          case_type: CaseType::APPEAL_TO_CROWN_COURT.to_s,
          appeal_original_app_submitted: 'no',
          appeal_lodged_date: Date.parse('2024-01-15'),
          appeal_maat_id: '1234567'
        }
      end

      it 'includes appeal_lodged_date' do
        expect(kase.appeal_lodged_date).to eq(Date.parse('2024-01-15'))
      end

      it 'includes appeal_original_app_submitted as no' do
        expect(kase.appeal_original_app_submitted).to eq('no')
      end

      it 'excludes financial circumstances details when original app not submitted' do
        expect(kase.appeal_financial_circumstances_changed).to be_nil
      end

      it 'excludes reference numbers' do
        expect(kase.appeal_maat_id).to be_nil
        expect(kase.appeal_usn).to be_nil
      end
    end

    describe 'Non-appeal case' do
      let(:attributes) do
        {
          case_type: CaseType::INDICTABLE.to_s,
          appeal_original_app_submitted: 'yes',
          appeal_financial_circumstances_changed: 'yes',
          appeal_lodged_date: Date.parse('2024-01-15'),
          appeal_with_changes_details: 'Some details',
          appeal_maat_id: '1234567'
        }
      end

      it 'excludes all appeal fields' do
        expect(kase.appeal_lodged_date).to be_nil
        expect(kase.appeal_original_app_submitted).to be_nil
        expect(kase.appeal_financial_circumstances_changed).to be_nil
        expect(kase.appeal_with_changes_details).to be_nil
        expect(kase.appeal_maat_id).to be_nil
        expect(kase.appeal_usn).to be_nil
        expect(kase.appeal_reference_number).to be_nil
      end
    end
  end
end
