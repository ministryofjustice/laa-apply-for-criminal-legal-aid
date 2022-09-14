require 'rails_helper'

RSpec.describe Decisions::CaseDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:kase) { instance_double(Case, codefendants: codefendants_double, charges: charges_double) }

  let(:codefendants_double) { double('codefendants_collection') }
  let(:charges_double) { double('charges_collection') }

  it_behaves_like 'a decision tree'

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  context 'when the step is `urn`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :urn }

    context 'has correct next step' do
      it { is_expected.to have_destination(:case_type, :edit, id: crime_application) }
    end
  end

  context 'when the step is `case_type`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :case_type }

    context 'has correct next step' do
      it { is_expected.to have_destination(:has_codefendants, :edit, id: crime_application) }
    end
  end

  context 'when the step is `has_codefendants`' do
    let(:form_object) { double('FormObject', case: kase, has_codefendants: has_codefendants) }
    let(:step_name) { :has_codefendants }

    context 'and answer is `no`' do
      let(:has_codefendants) { YesNoAnswer::NO }

      context 'and there are charges already' do
        let(:charges_double) { double(any?: true) }
        it { is_expected.to have_destination(:charges_summary, :edit, id: crime_application) }
      end

      context 'and there are no charges' do
        let(:charges_double) { double(any?: false, create!: 'charge') }
        it { is_expected.to have_destination(:charges, :edit, id: crime_application, charge_id: 'charge') }
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

          is_expected.to have_destination(:codefendants, :edit, id: crime_application)
        end
      end

      context 'and there are existing codefendants' do
        let(:codefendants_double) { double('codefendants_collection', empty?: false) }

        it 'redirects to the codefendants page' do
          is_expected.to have_destination(:codefendants, :edit, id: crime_application)
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

      is_expected.to have_destination(:codefendants, :edit, id: crime_application)
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

        is_expected.to have_destination(:codefendants, :edit, id: crime_application)
      end
    end

    context 'and there are other codefendants left' do
      let(:codefendants_double) { double('codefendants_collection', empty?: false) }

      it 'redirects to the codefendants page' do
        is_expected.to have_destination(:codefendants, :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `codefendants_finished`' do
    let(:form_object) { double('FormObject', case: kase) }
    let(:step_name) { :codefendants_finished }

    context 'and there are charges already' do
      let(:charges_double) { double(any?: true) }
      it { is_expected.to have_destination(:charges_summary, :edit, id: crime_application) }
    end

    context 'and there are no charges' do
      let(:charges_double) { double(any?: false, create!: 'charge') }
      it { is_expected.to have_destination(:charges, :edit, id: crime_application, charge_id: 'charge') }
    end
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
      it 'creates a blank new `charge` record, as well as a blank new associated `offence_date`' do
        expect(
          charges_double
        ).to receive(:create!).with(offence_dates_attributes: { id: nil })

        subject.destination
      end

      it { is_expected.to have_destination(:charges, :edit, id: crime_application, charge_id: 'charge') }
    end

    context 'and answer is `no`' do
      let(:add_offence) { YesNoAnswer::NO }
      it { is_expected.to have_destination('/home', :index, id: crime_application) }
    end
  end
end
