require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Decisions::CaseDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) {
    instance_double(
      CrimeApplication,
      id: '10',
      applicant: instance_double(Applicant),
      case: kase, # TODO: refactor the CaseDecisionTree to use #kase instead of #case
      kase: kase,
      non_means_tested?: non_means_tested,
      cifc?: cifc?,
    )
  }

  let(:kase) do
    instance_double(
      Case,
      case_type: CaseType::SUMMARY_ONLY,
      codefendants: codefendants_double,
      charges: charges_double,
    )
  end

  let(:codefendants_double) { double('codefendants_collection') }
  let(:charges_double) { double('charges_collection') }
  let(:is_means_tested) { nil }
  let(:non_means_tested) { nil }
  let(:cifc?) { false }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)

    allow(crime_application).to receive_messages(update: true, date_stamp: nil)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `urn`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :urn }

    it 'redirects to the `has_case_concluded` page' do
      expect(subject).to have_destination(:has_case_concluded, :edit, id: crime_application)
    end
  end

  context 'when the step is `has_case_concluded`' do
    let(:form_object) { double('FormObject', case: kase, has_case_concluded: has_case_concluded) }
    let(:step_name) { :has_case_concluded }

    context 'and answer is `yes`' do
      let(:has_case_concluded) { YesNoAnswer::YES }

      it 'redirects to the `is_preorder_work_claimed` page' do
        expect(subject).to have_destination(:is_preorder_work_claimed, :edit, id: crime_application)
      end
    end

    context 'and answer is `no`' do
      let(:has_case_concluded) { YesNoAnswer::NO }

      it 'redirects to the `is_client_remanded` page' do
        expect(subject).to have_destination(:is_client_remanded, :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `is_preorder_work_claimed`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :is_preorder_work_claimed }

    context 'when application is not means tested' do
      let(:is_means_tested) { 'no' }
      let(:non_means_tested) { true }

      context 'and there are no charges yet' do
        let(:charges_double) { double(any?: false, create!: 'charge', reject: nil) }

        it { is_expected.to have_destination(:charges, :edit, id: crime_application, charge_id: 'charge') }
      end

      context 'and there are already charges' do
        let(:charges_double) { double(any?: true) }

        it { is_expected.to have_destination(:charges_summary, :edit, id: crime_application) }
      end
    end

    context 'when application is means tested' do
      it 'redirects to the `is_client_remanded` page' do
        expect(subject).to have_destination(:is_client_remanded, :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `is_client_remanded`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :is_client_remanded }

    context 'and there are no charges yet' do
      let(:charges_double) { double(any?: false, create!: 'charge', reject: nil) }

      it { is_expected.to have_destination(:charges, :edit, id: crime_application, charge_id: 'charge') }
    end

    context 'and there are already charges' do
      let(:charges_double) { double(any?: true) }

      it { is_expected.to have_destination(:charges_summary, :edit, id: crime_application) }
    end

    context 'and it is a change in financial circumstances application' do
      let(:cifc?) { true }

      context 'when means assessment required' do
        before do
          allow(subject).to receive(:requires_means_assessment?).and_return(true)
        end

        it { is_expected.to have_destination('/steps/income/employment_status', :edit, id: crime_application) }
      end

      context 'when means assessment not required' do
        before do
          allow(subject).to receive(:requires_means_assessment?).and_return(false)
        end

        it { is_expected.to have_destination('/steps/evidence/upload', :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `has_codefendants`' do
    let(:form_object) { double('FormObject', case: kase, has_codefendants: has_codefendants) }
    let(:step_name) { :has_codefendants }

    context 'and answer is `no`' do
      let(:has_codefendants) { YesNoAnswer::NO }

      context 'and the `other charges in progress` question is required' do
        before { allow(subject).to receive(:require_other_charge_in_progress?).with('client').and_return(true) }

        it {
          expect(subject).to have_destination(:other_charge_in_progress, :edit, id: crime_application,
subject: 'client')
        }
      end

      context 'and the `other charges in progress` question is not required' do
        before { allow(subject).to receive(:require_other_charge_in_progress?).with('client').and_return(false) }

        it { is_expected.to have_destination(:hearing_details, :edit, id: crime_application) }
      end
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

    context 'and the `other charges in progress` question is required' do
      before { allow(subject).to receive(:require_other_charge_in_progress?).with('client').and_return(true) }

      it { is_expected.to have_destination(:other_charge_in_progress, :edit, id: crime_application, subject: 'client') }
    end

    context 'and the `other charges in progress` question is not required' do
      before { allow(subject).to receive(:require_other_charge_in_progress?).with('client').and_return(false) }

      it { is_expected.to have_destination(:hearing_details, :edit, id: crime_application) }
    end
  end

  context 'when the step is `charges`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :charges }

    context 'has correct next step' do
      it { is_expected.to have_destination(:charges_dates, :edit, id: crime_application) }
    end
  end

  context 'when the step is `charges_dates`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :charges_dates }

    context 'has correct next step' do
      it { is_expected.to have_destination(:charges_summary, :edit, id: crime_application) }
    end
  end

  context 'when the step is `charges_summary`' do
    let(:form_object) { double('FormObject', case: kase, add_offence: add_offence) }
    let(:step_name) { :charges_summary }

    context 'and answer is `yes`' do
      let(:add_offence) { YesNoAnswer::YES }
      let(:charges_double) { double(create!: 'charge', reject: nil) }

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

      it { is_expected.to have_destination(:charges_dates, :edit, id: crime_application, charge_id: charge) }
    end
  end

  context 'when the step is `delete_offence_date`' do
    context 'has correct next step' do
      let(:step_name) { :delete_offence_date }
      let(:charge) { Charge.new(id: '20') }
      let(:form_object) { double('FormObject', case: kase, record: charge) }

      it { is_expected.to have_destination(:charges_dates, :edit, id: crime_application, charge_id: charge) }
    end
  end

  context 'when the step is `hearing_details`' do
    let(:form_object) { double('FormObject', is_first_court_hearing:) }
    let(:step_name) { :hearing_details }

    context 'when court did not hear first hearing' do
      let(:is_first_court_hearing) { FirstHearingAnswer::NO }

      it { is_expected.to have_destination(:first_court_hearing, :edit, id: crime_application) }
    end

    context 'when court did hear first hearing' do
      let(:is_first_court_hearing) { FirstHearingAnswer::YES }

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
  end

  context 'when the step is `first_court_hearing`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :first_court_hearing }

    it 'runs the `ioj_or_passported` logic' do
      expect(subject).to receive(:ioj_or_passported)
      subject.destination
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
      allow(subject).to receive(:requires_means_assessment?).and_return(
        requires_means_assessment?
      )
    end

    context 'when requires means assessment' do
      let(:requires_means_assessment?) { true }

      it { is_expected.to have_destination('/steps/income/employment_status', :edit, id: crime_application) }
    end

    context 'when does not require mean assessment' do
      let(:requires_means_assessment?) { false }

      it { is_expected.to have_destination('/steps/evidence/upload', :edit, id: crime_application) }
    end
  end

  context 'when the step is `other_charge_in_progress`' do
    let(:form_object) { double('FormObject', case: kase, form_subject: double('FormSubject', to_param: form_subject)) }
    let(:step_name) { :other_charge_in_progress }
    let(:form_subject) { nil }

    context 'when the subject is the client' do
      let(:form_subject) { 'client' }

      context 'and the `other charge` question is required' do
        before { allow(subject).to receive(:require_other_charge?).with(form_subject).and_return(true) }

        it { is_expected.to have_destination(:other_charge, :edit, id: crime_application, subject: form_subject) }
      end

      context 'when the `other charge` question is not required' do
        before { allow(subject).to receive(:require_other_charge?).with(form_subject).and_return(false) }

        context 'and the `other charge in progress` question is required for the partner' do
          before { allow(subject).to receive(:require_other_charge_in_progress?).with('partner').and_return(true) }

          it {
            expect(subject).to have_destination(:other_charge_in_progress, :edit, id: crime_application,
subject: 'partner')
          }
        end

        context 'and the `other charge in progress` question is not required for the partner' do
          before { allow(subject).to receive(:require_other_charge_in_progress?).with('partner').and_return(false) }

          it { is_expected.to have_destination(:hearing_details, :edit, id: crime_application) }
        end
      end
    end

    context 'when the subject is the partner' do
      let(:form_subject) { 'partner' }

      context 'and the `other charge` question is required' do
        before { allow(subject).to receive(:require_other_charge?).with(form_subject).and_return(true) }

        it { is_expected.to have_destination(:other_charge, :edit, id: crime_application, subject: form_subject) }
      end

      context 'when the `other charge` question is not required' do
        before { allow(subject).to receive(:require_other_charge?).with(form_subject).and_return(false) }

        it { is_expected.to have_destination(:hearing_details, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `other_charge`' do
    let(:form_object) { double('FormObject', case: kase, form_subject: double('FormSubject', to_param: form_subject)) }
    let(:step_name) { :other_charge }
    let(:form_subject) { nil }

    context 'when the subject is the client' do
      let(:form_subject) { 'client' }

      context 'and the `other charge in progress` question is required for the partner' do
        before { allow(subject).to receive(:require_other_charge_in_progress?).with('partner').and_return(true) }

        it {
          expect(subject).to have_destination(:other_charge_in_progress, :edit, id: crime_application,
subject: 'partner')
        }
      end

      context 'and the `other charge in progress` question is not required for the partner' do
        before { allow(subject).to receive(:require_other_charge_in_progress?).with('partner').and_return(false) }

        it { is_expected.to have_destination(:hearing_details, :edit, id: crime_application) }
      end
    end

    context 'when the subject is the partner' do
      let(:form_subject) { 'partner' }

      it { is_expected.to have_destination(:hearing_details, :edit, id: crime_application) }
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
