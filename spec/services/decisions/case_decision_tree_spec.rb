require 'rails_helper'

RSpec.describe Decisions::CaseDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication, id: '10', applicant: applicant_double, case: kase) }
  let(:kase) { instance_double(Case, codefendants: codefendants_double, charges: charges_double) }

  let(:codefendants_double) { double('codefendants_collection') }
  let(:charges_double) { double('charges_collection') }
  let(:applicant_double) { double('applicant') }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)

    allow(crime_application).to receive(:update).and_return(true)
    allow(crime_application).to receive(:date_stamp).and_return(nil)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `case_type`' do
    let(:form_object) { double('FormObject', case: kase, case_type: CaseType.new(case_type)) }
    let(:step_name) { :case_type }

    context 'and the case type is `appeal_to_crown_court`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT.to_s }

      it { is_expected.to have_destination(:appeal_details, :edit, id: crime_application) }
    end

    context 'and the case type is `appeal_to_crown_court_with_changes`' do
      let(:case_type) { CaseType::APPEAL_TO_CROWN_COURT_WITH_CHANGES.to_s }

      it { is_expected.to have_destination(:appeal_details, :edit, id: crime_application) }
    end

    context 'and the application already has a date stamp' do
      before do
        allow(crime_application).to receive(:date_stamp) { Time.zone.today }
        allow(kase).to receive(:case_type).and_return(case_type)
      end

      let(:case_type) { CaseType::SUMMARY_ONLY.to_s }

      it { is_expected.to have_destination(:urn, :edit, id: crime_application) }
    end

    context 'and the application has no date stamp' do
      before do
        allow(crime_application).to receive(:date_stamp)
        allow(kase).to receive(:case_type).and_return(case_type)
      end

      context 'and the case type is "date stampable"' do
        let(:charges_double) { double(any?: false, create!: 'charge') }
        let(:case_type) { CaseType::SUMMARY_ONLY.to_s }

        it { is_expected.to have_destination(:date_stamp, :edit, id: crime_application) }
      end

      context 'and case type is not "date stampable"' do
        let(:case_type) { CaseType::INDICTABLE.to_s }

        it { is_expected.to have_destination(:urn, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `appeal_details`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :appeal_details }

    # We've tested this logic for non-appeals, no need to test again
    # as this step runs the same method/code
    it 'performs the date stamp logic' do
      expect(subject).to receive(:date_stamp_if_needed)
      subject.destination
    end
  end

  context 'when the step is `date_stamp`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :date_stamp }

    it { is_expected.to have_destination(:urn, :edit, id: crime_application) }
  end

  context 'when the step is `urn`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :urn }

    context 'and there are no charges yet' do
      let(:charges_double) { double(any?: false, create!: 'charge') }

      it { is_expected.to have_destination(:charges, :edit, id: crime_application, charge_id: 'charge') }
    end

    context 'and there are already charges' do
      let(:charges_double) { double(any?: true) }

      it { is_expected.to have_destination(:charges_summary, :edit, id: crime_application) }
    end
  end

  context 'when the step is `has_codefendants`' do
    let(:form_object) { double('FormObject', case: kase, has_codefendants: has_codefendants) }
    let(:step_name) { :has_codefendants }

    context 'and answer is `no`' do
      let(:has_codefendants) { YesNoAnswer::NO }

      it { is_expected.to have_destination(:hearing_details, :edit, id: crime_application) }
    end

    context 'and answer is `yes`' do
      let(:has_codefendants) { YesNoAnswer::YES }

      context 'and there are no other codefendants yet' do
        let(:codefendants_double) { double('codefendants_collection', empty?: true) }

        it 'creates a blank co-defendant record and redirects to the codefendants page' do
          expect(
            codefendants_double
          ).to receive(:create!).at_least(:once)

          expect(subject).to have_destination(:codefendants, :edit, id: crime_application)
        end
      end

      context 'and there are existing codefendants' do
        let(:codefendants_double) { double('codefendants_collection', empty?: false) }

        it 'redirects to the codefendants page' do
          expect(subject).to have_destination(:codefendants, :edit, id: crime_application)
        end
      end
    end
  end

  context 'when the step is `add_codefendant`' do
    let(:form_object) { double('FormObject', case: kase) }
    let(:step_name) { :add_codefendant }

    it 'creates a blank co-defendant record and redirects to the codefendants page' do
      expect(
        codefendants_double
      ).to receive(:create!).at_least(:once)

      expect(subject).to have_destination(:codefendants, :edit, id: crime_application)
    end
  end

  context 'when the step is `delete_codefendant`' do
    let(:form_object) { double('FormObject', case: kase) }
    let(:step_name) { :delete_codefendant }

    # Technically the interface will not allow this possibility as we don't allow
    # deleting the last remaining record, but the test exists as a sanity check.
    context 'and there are no other codefendants left' do
      let(:codefendants_double) { double('codefendants_collection', empty?: true) }

      it 'creates a blank co-defendant record and redirects to the codefendants page' do
        expect(
          codefendants_double
        ).to receive(:create!).at_least(:once)

        expect(subject).to have_destination(:codefendants, :edit, id: crime_application)
      end
    end

    context 'and there are other codefendants left' do
      let(:codefendants_double) { double('codefendants_collection', empty?: false) }

      it 'redirects to the codefendants page' do
        expect(subject).to have_destination(:codefendants, :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `codefendants_finished`' do
    let(:form_object) { double('FormObject', case: kase) }
    let(:step_name) { :codefendants_finished }

    it { is_expected.to have_destination(:hearing_details, :edit, id: crime_application) }
  end

  context 'when the step is `charges`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :charges }

    context 'has correct next step' do
      it { is_expected.to have_destination(:charges_summary, :edit, id: crime_application) }
    end
  end

  context 'when the step is `charges_summary`' do
    let(:form_object) { double('FormObject', case: kase, add_offence: add_offence) }
    let(:step_name) { :charges_summary }

    context 'and answer is `yes`' do
      let(:add_offence) { YesNoAnswer::YES }
      let(:charges_double) { double(create!: 'charge') }

      # No need to repeat this test, just once is enough as sanity check
      it 'creates a blank new `charge` record' do
        expect(charges_double).to receive(:create!)
        subject.destination
      end

      it { is_expected.to have_destination(:charges, :edit, id: crime_application, charge_id: 'charge') }
    end

    context 'and answer is `no`' do
      let(:add_offence) { YesNoAnswer::NO }

      it { is_expected.to have_destination(:has_codefendants, :edit, id: crime_application) }
    end
  end

  context 'when the step is `add_offence_date`' do
    context 'has correct next step' do
      let(:step_name) { :add_offence_date }
      let(:offence_dates) { [OffenceDate.new(date_from: '01, 02, 2000')] }
      let(:charge) { Charge.new(id: '20', offence_dates: offence_dates) }
      let(:form_object) { double('FormObject', case: kase, record: charge) }

      it { is_expected.to have_destination(:charges, :edit, id: crime_application, charge_id: charge) }
    end
  end

  context 'when the step is `delete_offence_date`' do
    context 'has correct next step' do
      let(:step_name) { :delete_offence_date }
      let(:charge) { Charge.new(id: '20') }
      let(:form_object) { double('FormObject', case: kase, record: charge) }

      it { is_expected.to have_destination(:charges, :edit, id: crime_application, charge_id: charge) }
    end
  end

  context 'when the step is `hearing_details`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :hearing_details }

    before do
      allow_any_instance_of(Passporting::IojPassporter).to receive(:call).and_return(ioj_passported)
    end

    context 'and the IoJ passporter was not triggered' do
      let(:ioj_passported) { false }

      it { is_expected.to have_destination(:ioj, :edit, id: crime_application) }
    end

    context 'and the IoJ passporter was triggered' do
      let(:ioj_passported) { true }

      it { is_expected.to have_destination(:ioj_passport, :edit, id: crime_application) }
    end
  end

  context 'when the step is `ioj_passport`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :ioj_passport }

    it 'runs the same logic as the `ioj` step' do
      expect(subject).to receive(:after_ioj)
      subject.destination
    end
  end

  context 'when the step is `ioj`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :ioj }

    before do
      allow_any_instance_of(Passporting::MeansPassporter).to receive(:call).and_return(means_passported)
    end

    context 'and the means passporter was not triggered' do
      let(:means_passported) { false }

      it 'raises an error' do
        expect {
          subject.destination
        }.to raise_error(
          Decisions::BaseDecisionTree::InvalidStep, 'application is not means-passported'
        )
      end
    end

    context 'and the means passporter was triggered' do
      let(:means_passported) { true }

      before do
        allow(FeatureFlags).to receive(:evidence_upload) {
          instance_double(FeatureFlags::EnabledFeature, enabled?: feat_enabled)
        }
      end

      context 'and the evidence upload feature flag is disabled' do
        let(:feat_enabled) {false}

        it { is_expected.to have_destination('/steps/submission/review', :edit, id: crime_application) }
      end

      context 'and the evidence upload feature flag is enabled' do
        let(:feat_enabled) {true}

        it { is_expected.to have_destination('/steps/evidence/upload', :edit, id: crime_application) }
      end
    end
  end
end
