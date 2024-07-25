require 'rails_helper'

RSpec.describe CaseDetails::AnswersValidator, type: :model do
  subject(:validator) { described_class.new(record) }

  let(:record) { instance_double(Case, crime_application:, errors:) }
  let(:crime_application) do
    instance_double(CrimeApplication, non_means_tested?: non_means_tested, cifc?: cifc?)
  end
  let(:errors) { double(:errors) }
  let(:non_means_tested) { false }
  let(:cifc?) { false }

  describe '#validate' do
    before { allow(record).to receive_messages(**attributes) }

    context 'when all validations pass' do
      let(:errors) { double(empty?: true) }

      let(:attributes) do
        {
          has_case_concluded: 'no',
          has_codefendants: 'no',
          is_client_remanded: 'no',
          values_at: [1],
          is_first_court_hearing: 'yes',
          charges: [double(complete?: true)],
          codefendants: [double(complete?: true)],
          first_court_hearing_name: nil,
        }
      end

      it 'does not add any errors' do
        subject.validate
      end
    end

    context 'when validation fails' do
      let(:errors) { double(empty?: false) }

      let(:attributes) do
        {
          has_case_concluded: 'yes',
          date_case_concluded: nil,
          is_preorder_work_claimed: 'yes',
          is_client_remanded: nil,
          charges: [double(complete?: false)],
          has_codefendants: 'yes',
          codefendants: [double(complete?: false)],
          is_first_court_hearing: 'no',
          first_court_hearing_name: nil,
          values_at: [nil]
        }
      end

      it 'adds errors for all failed validations' do # rubocop:disable RSpec/MultipleExpectations
        expect(errors).to receive(:add).with(:has_case_concluded, :blank)
        expect(errors).to receive(:add).with(:is_preorder_work_claimed, :blank)
        expect(errors).to receive(:add).with(:is_client_remanded, :blank)
        expect(errors).to receive(:add).with(:charges, :blank)
        expect(errors).to receive(:add).with(:charges_summary, :incomplete_records)
        expect(errors).to receive(:add).with(:codefendants_summary, :incomplete_records)
        expect(errors).to receive(:add).with(:hearing_details, :blank)
        expect(errors).to receive(:add).with(:first_court_hearing, :blank)

        expect(errors).to receive(:add).with(:base, :incomplete_records)

        subject.validate
      end

      # rubocop:disable RSpec/MultipleExpectations
      context 'when application is non means tested' do
        let(:non_means_tested) { true }

        it 'adds errors for all failed validations' do
          expect(errors).to receive(:add).with(:has_case_concluded, :blank)
          expect(errors).to receive(:add).with(:is_preorder_work_claimed, :blank)
          expect(errors).to receive(:add).with(:hearing_details, :blank)
          expect(errors).to receive(:add).with(:charges, :blank)
          expect(errors).to receive(:add).with(:charges_summary, :incomplete_records)
          expect(errors).to receive(:add).with(:codefendants_summary, :incomplete_records)
          expect(errors).to receive(:add).with(:first_court_hearing, :blank)

          expect(errors).to receive(:add).with(:base, :incomplete_records)

          subject.validate
        end
      end
      # rubocop:enable RSpec/MultipleExpectations
    end

    context 'with change in financial circumstances application' do
      let(:cifc?) { true }
      let(:errors) { double(empty?: true) }

      let(:attributes) do
        {
          has_case_concluded: 'no',
          has_codefendants: 'no',
          is_client_remanded: 'no',
          is_first_court_hearing: nil,
          charges: [],
          codefendants: [],
          first_court_hearing_name: nil,
          hearing_court_name: nil,
          hearing_date: nil,
        }
      end

      before do
        allow(FeatureFlags).to receive(:cifc_journey) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: true)
        }
      end

      it 'passes validation' do
        subject.validate
      end
    end
  end

  describe '#case_concluded_complete?' do
    context 'when case concluded is missing' do
      before { allow(record).to receive(:has_case_concluded).and_return(nil) }

      it 'returns false' do
        expect(subject.case_concluded_complete?).to be(false)
      end
    end

    context 'when case concluded is no' do
      before { allow(record).to receive(:has_case_concluded).and_return('no') }

      it 'returns true' do
        expect(subject.case_concluded_complete?).to be(true)
      end
    end

    context 'when case concluded is yes but date case concluded is missing' do
      before do
        allow(record).to receive_messages(has_case_concluded: 'yes', date_case_concluded: nil)
      end

      it 'returns false' do
        expect(subject.case_concluded_complete?).to be(false)
      end
    end

    context 'when case concluded is yes and date case concluded is present' do
      before do
        allow(record).to receive_messages(has_case_concluded: 'yes', date_case_concluded: Time.zone.today)
      end

      it 'returns true' do
        expect(subject.case_concluded_complete?).to be(true)
      end
    end
  end

  describe '#preorder_work_complete?' do
    before do
      allow(record).to receive_messages(
        has_case_concluded:, is_preorder_work_claimed:, preorder_work_date:, preorder_work_details:
      )

      allow(record).to receive(:values_at).with(
        :is_preorder_work_claimed, :preorder_work_date, :preorder_work_details
      ) { [is_preorder_work_claimed, preorder_work_date, preorder_work_details] }
    end

    let(:has_case_concluded) { nil }
    let(:is_preorder_work_claimed) { nil }
    let(:preorder_work_date) { nil }
    let(:preorder_work_details) { nil }

    context 'when case has not concluded' do
      it 'returns true' do
        expect(subject.preorder_work_complete?).to be(true)
      end
    end

    context 'when case has concluded but preorder work is not claimed' do
      let(:has_case_concluded) { 'yes' }
      let(:is_preorder_work_claimed) { 'no' }

      it 'returns true' do
        expect(subject.preorder_work_complete?).to be(true)
      end
    end

    context 'when case has concluded and preorder work is claimed' do
      let(:has_case_concluded) { 'yes' }
      let(:is_preorder_work_claimed) { 'yes' }

      context 'when all preorder work details are present' do
        let(:preorder_work_date) { Time.zone.today }
        let(:preorder_work_details) { 'Work details' }

        it 'returns true' do
          expect(subject.preorder_work_complete?).to be(true)
        end
      end

      context 'when any preorder work detail is missing' do
        let(:preorder_work_date) { Time.zone.today }

        it 'returns false' do
          expect(subject.preorder_work_complete?).to be(false)
        end
      end
    end
  end

  describe '#client_remanded_complete?' do
    before do
      allow(record).to receive_messages(is_client_remanded:, date_client_remanded:)

      allow(record).to receive(:values_at).with(:date_client_remanded) {
        [date_client_remanded]
      }
    end

    let(:is_client_remanded) { nil }
    let(:date_client_remanded) { nil }

    context 'when client remand status is blank' do
      it 'returns false' do
        expect(subject.client_remanded_complete?).to be(false)
      end
    end

    context 'when client is not remanded' do
      let(:is_client_remanded) { 'no' }

      it 'returns true' do
        expect(subject.client_remanded_complete?).to be(true)
      end
    end

    context 'when client is remanded' do
      let(:is_client_remanded) { 'yes' }

      context 'when date client remanded is present' do
        let(:date_client_remanded) { Time.zone.today }

        it 'returns true' do
          expect(subject.client_remanded_complete?).to be(true)
        end
      end

      context 'when date client remanded is missing' do
        let(:date_client_remanded) { nil }

        it 'returns false' do
          expect(subject.client_remanded_complete?).to be(false)
        end
      end
    end
  end

  describe '#hearing_details_complete?' do
    before do
      allow(record).to receive_messages(
        hearing_court_name:, hearing_date:, is_first_court_hearing:
      )

      allow(record).to receive(:values_at).with(:hearing_court_name, :hearing_date, :is_first_court_hearing) {
        [hearing_court_name, hearing_date, is_first_court_hearing]
      }
    end

    let(:hearing_court_name) { nil }
    let(:hearing_date) { nil }
    let(:is_first_court_hearing) { nil }

    context 'when hearing details are present' do
      let(:hearing_court_name) { 'Court Name' }
      let(:hearing_date) { Time.zone.today }
      let(:is_first_court_hearing) { true }

      it 'returns true' do
        expect(subject.hearing_details_complete?).to be(true)
      end
    end

    context 'when any hearing detail is missing' do
      let(:hearing_court_name) { 'Court Name' }
      let(:hearing_date) { nil }
      let(:is_first_court_hearing) { true }

      it 'returns false' do
        expect(subject.hearing_details_complete?).to be(false)
      end
    end

    context 'when all hearing details are missing' do
      let(:hearing_court_name) { nil }
      let(:hearing_date) { nil }
      let(:is_first_court_hearing) { nil }

      it 'returns false' do
        expect(subject.hearing_details_complete?).to be(false)
      end
    end
  end

  describe 'charges' do
    let(:charges) { [] }

    before do
      allow(record).to receive(:charges).and_return(charges)
    end

    context 'when there are no charges' do
      it '#has_charges_complete? returns false' do
        expect(subject.has_charges_complete?).to be(false)
      end

      it '#all_charges_complete? returns false' do
        expect(subject.all_charges_complete?).to be(true)
      end
    end

    context 'when there are charges' do
      let(:charge1) { double('Charge', complete?: true) }
      let(:charge2) { double('Charge', complete?: false) }
      let(:charges) { [charge1, charge2] }

      it '#has_charges_complete? returns true' do
        expect(subject.has_charges_complete?).to be(true)
      end

      it '#all_charges_complete? returns false' do
        expect(subject.all_charges_complete?).to be(false)
      end
    end

    context 'when all charges are complete' do
      let(:charge1) { double('Charge', complete?: true) }
      let(:charge2) { double('Charge', complete?: true) }
      let(:charges) { [charge1, charge2] }

      it '#has_charges_complete? returns true' do
        expect(subject.has_charges_complete?).to be(true)
      end

      it '#all_charges_complete? returns true' do
        expect(subject.all_charges_complete?).to be(true)
      end
    end
  end

  describe 'codefendants' do
    let(:codefendants) { [] }
    let(:has_codefendants) { nil }

    before do
      allow(record).to receive_messages(codefendants:, has_codefendants:)
    end

    context 'when there are no codefendants' do
      it '#has_codefendants_complete? returns false' do
        expect(subject.has_codefendants_complete?).to be(false)
      end

      it '#all_codefendants_complete? returns true' do
        expect(subject.all_codefendants_complete?).to be(true)
      end
    end

    context 'when there are codefendants' do
      let(:has_codefendants) { 'yes' }
      let(:codefendant1) { double('codefendant', complete?: true) }
      let(:codefendant2) { double('codefendant', complete?: false) }
      let(:codefendants) { [codefendant1, codefendant2] }

      it '#has_codefendants_complete? returns true' do
        expect(subject.has_codefendants_complete?).to be(true)
      end

      it '#all_codefendants_complete? returns false' do
        expect(subject.all_codefendants_complete?).to be(false)
      end
    end

    context 'when all codefendants are complete' do
      let(:has_codefendants) { 'yes' }
      let(:codefendant1) { double('codefendant', complete?: true) }
      let(:codefendant2) { double('codefendant', complete?: true) }
      let(:codefendants) { [codefendant1, codefendant2] }

      it '#has_codefendants_complete? returns true' do
        expect(subject.has_codefendants_complete?).to be(true)
      end

      it '#all_codefendants_complete? returns true' do
        expect(subject.all_codefendants_complete?).to be(true)
      end
    end
  end

  describe '#first_court_hearing_complete?' do
    let(:is_first_court_hearing) { nil }
    let(:first_court_hearing_name) { nil }

    before do
      allow(record).to receive_messages(is_first_court_hearing:, first_court_hearing_name:)
    end

    context 'when first court hearing is not required' do
      let(:is_first_court_hearing) { 'yes' }

      it 'returns true' do
        expect(subject.first_court_hearing_complete?).to be(true)
      end
    end

    context 'when first court hearing is required' do
      let(:is_first_court_hearing) { 'no' }

      context 'when first court hearing name is present' do
        let(:first_court_hearing_name) { 'Cardiff Crown Court' }

        it 'returns true' do
          expect(subject.first_court_hearing_complete?).to be(true)
        end
      end

      context 'when first court hearing name is not present' do
        let(:first_court_hearing_name) { nil }

        it 'returns false' do
          expect(subject.first_court_hearing_complete?).to be(false)
        end
      end
    end
  end
end
