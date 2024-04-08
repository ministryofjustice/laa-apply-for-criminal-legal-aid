require 'rails_helper'

RSpec.describe Decisions::IncomeDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
      income: income,
      dependants: dependants_double,
      case: kase,
    )
  end

  let(:income) { instance_double(Income, employment_status:) }
  let(:employment_status) { nil }
  let(:dependants_double) { double('dependants_collection') }
  let(:kase) { instance_double(Case, case_type:) }
  let(:case_type) { nil }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `employment_status`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :employment_status }

    context 'when status selected is an employed option' do
      let(:employment_status) { [EmploymentStatus::EMPLOYED.to_s] }

      before do
        allow(form_object).to receive(:employment_status).and_return([EmploymentStatus::EMPLOYED])
      end

      it { is_expected.to have_destination(:employed_exit, :show, id: crime_application) }
    end

    context 'when status selected is not working' do
      let(:employment_status) { EmploymentStatus::NOT_WORKING.to_s }

      context 'when employment ended within 3 months' do
        before do
          allow(form_object).to receive_messages(employment_status: [EmploymentStatus::NOT_WORKING.to_s],
                                                 ended_employment_within_three_months: YesNoAnswer::YES)
        end

        it { is_expected.to have_destination(:lost_job_in_custody, :edit, id: crime_application) }
      end

      context 'when employment has not ended within 3 months' do
        before do
          allow(form_object).to receive_messages(employment_status: [EmploymentStatus::NOT_WORKING.to_s],
                                                 ended_employment_within_three_months: YesNoAnswer::NO)
        end

        context 'when case_type is not appeal no changes' do
          let(:case_type) { 'summary_only' }

          it { is_expected.to have_destination(:income_before_tax, :edit, id: crime_application) }
        end

        context 'when case_type is appeal no changes' do
          let(:case_type) { 'appeal_to_crown_court' }

          it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
        end
      end
    end
  end

  context 'when the step is `lost_job_in_custody`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :lost_job_in_custody }

    context 'when case_type is not appeal no changes' do
      let(:case_type) { 'summary_only' }

      it { is_expected.to have_destination(:income_before_tax, :edit, id: crime_application) }
    end

    context 'when case_type is appeal no changes' do
      let(:case_type) { 'appeal_to_crown_court' }

      it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
    end
  end

  context 'when the step is `income_before_tax`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :income_before_tax }

    before do
      allow(income).to receive_messages(income_above_threshold:)
    end

    context 'when income is above the threshold' do
      let(:income_above_threshold) { YesNoAnswer::YES.to_s }

      it { is_expected.to have_destination(:income_payments, :edit, id: crime_application) }
    end

    context 'when income below the threshold' do
      let(:income_above_threshold) { YesNoAnswer::NO.to_s }

      it { is_expected.to have_destination(:frozen_income_savings_assets, :edit, id: crime_application) }
    end
  end

  context 'when the step is `frozen_income_savings_assets`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :frozen_income_savings_assets }

    before do
      allow(income).to receive_messages(has_frozen_income_or_assets:)
    end

    context 'when they have frozen income or assets' do
      let(:has_frozen_income_or_assets) { YesNoAnswer::YES.to_s }

      it { is_expected.to have_destination(:income_payments, :edit, id: crime_application) }
    end

    context 'when they do not have frozen income or assets' do
      let(:has_frozen_income_or_assets) { YesNoAnswer::NO.to_s }

      context 'when case type is not summary only' do
        let(:case_type) { 'indictable' }

        it { is_expected.to have_destination(:client_owns_property, :edit, id: crime_application) }
      end

      context 'when case type is summary only' do
        let(:case_type) { 'summary_only' }

        it { is_expected.to have_destination(:income_payments, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `client_owns_property`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :client_owns_property }

    before do
      allow(income).to receive_messages(client_owns_property:)
    end

    context 'when they have property' do
      let(:client_owns_property) { YesNoAnswer::YES.to_s }

      it { is_expected.to have_destination(:income_payments, :edit, id: crime_application) }
    end

    context 'when they do not have property' do
      let(:client_owns_property) { YesNoAnswer::NO.to_s }

      it { is_expected.to have_destination(:has_savings, :edit, id: crime_application) }
    end
  end

  context 'when the step is `has savings`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :has_savings }

    context 'has correct next step' do
      it { is_expected.to have_destination(:income_payments, :edit, id: crime_application) }
    end
  end

  context 'when the step is `income payments`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :income_payments }

    context 'has correct next step' do
      it { is_expected.to have_destination(:income_benefits, :edit, id: crime_application) }
    end
  end

  context 'when the step is `income benefits`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :income_benefits }

    before do
      allow(income).to receive_messages(
        income_above_threshold:,
        has_frozen_income_or_assets:,
        client_owns_property:,
        has_savings:
      )
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context 'when dependants are relevant' do
      let(:income_above_threshold) { YesNoAnswer::YES.to_s }
      let(:has_frozen_income_or_assets) { YesNoAnswer::YES.to_s }
      let(:client_owns_property) { YesNoAnswer::NO.to_s }
      let(:has_savings) { YesNoAnswer::NO.to_s }

      it { is_expected.to have_destination(:client_has_dependants, :edit, id: crime_application) }
    end

    context 'when dependants are not relevant' do
      let(:income_above_threshold) { YesNoAnswer::NO.to_s }
      let(:has_frozen_income_or_assets) { YesNoAnswer::NO.to_s }
      let(:client_owns_property) { YesNoAnswer::NO.to_s }
      let(:has_savings) { YesNoAnswer::NO.to_s }
      let(:income_benefits) { [] }

      before do
        allow(crime_application).to receive_messages(income_payments:, income_benefits:)
      end

      context 'when there are no payments' do
        let(:income_payments) { [] }

        it { is_expected.to have_destination(:manage_without_income, :edit, id: crime_application) }
      end

      context 'when there are payments' do
        let(:income_payments) { [{ amount: 1234 }] }

        it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `client_has_dependants`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :client_has_dependants }

    context 'when client does not have dependants' do
      before do
        allow(form_object).to receive(:client_has_dependants).and_return(YesNoAnswer::NO)
      end

      context 'when there are no payments' do
        before do
          allow(crime_application).to receive_messages(income_payments: [], income_benefits: [])
        end

        it { is_expected.to have_destination(:manage_without_income, :edit, id: crime_application) }
      end

      context 'when there are payments' do
        before do
          allow(crime_application).to receive_messages(income_payments: [{ amount: 1234 }], income_benefits: [])

          allow(income).to receive_messages(
            income_above_threshold:,
            has_frozen_income_or_assets:,
            client_owns_property:,
            has_savings:
          )
        end

        let(:income_above_threshold) { YesNoAnswer::NO.to_s }
        let(:has_frozen_income_or_assets) { YesNoAnswer::NO.to_s }
        let(:client_owns_property) { YesNoAnswer::NO.to_s }
        let(:has_savings) { YesNoAnswer::NO.to_s }

        it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
      end
    end

    context 'when client does have dependants' do
      before do
        allow(form_object).to receive(:client_has_dependants).and_return(YesNoAnswer::YES)
      end

      it 'creates a blank dependant record and redirects to the dependants page' do
        expect(
          dependants_double
        ).to receive(:create!).at_least(:once)

        expect(subject).to have_destination(:dependants, :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `add_dependant`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :add_dependant }

    it 'creates a blank dependant record and redirects to the dependants page' do
      expect(dependants_double).to receive(:create!).at_least(:once)
      expect(subject).to have_destination(:dependants, :edit, id: crime_application)
    end
  end

  context 'when the step is `delete_dependant`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :delete_dependant }

    # Technically the interface will not allow this possibility as we don't allow
    # deleting the last remaining record, but the test exists as a sanity check.
    # (See Codefendants behaviour/UX)
    context 'and there are no other dependants left' do
      let(:dependants_double) { double('dependants_collection', empty?: true) }

      it 'creates a blank dependant record and redirects to the dependants page' do
        expect(dependants_double).to receive(:create!).at_least(:once)
        expect(subject).to have_destination(:dependants, :edit, id: crime_application)
      end
    end

    context 'and there are other dependants left' do
      let(:dependants_double) { double('dependants_collection', empty?: false) }

      it 'redirects to the dependants page' do
        expect(subject).to have_destination(:dependants, :edit, id: crime_application)
      end
    end
  end

  context 'when the step is `dependants_finished`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :dependants_finished }

    context 'when there are no payments' do
      before do
        allow(crime_application).to receive_messages(income_payments: [], income_benefits: [])
      end

      it { is_expected.to have_destination(:manage_without_income, :edit, id: crime_application) }
    end

    context 'when there are payments' do
      before do
        allow(crime_application).to receive_messages(income_payments: [{ amount: 1234 }], income_benefits: [])

        allow(income).to receive_messages(
          income_above_threshold:,
          has_frozen_income_or_assets:,
          client_owns_property:,
          has_savings:
        )
      end

      let(:income_above_threshold) { YesNoAnswer::NO.to_s }
      let(:has_frozen_income_or_assets) { YesNoAnswer::NO.to_s }
      let(:client_owns_property) { YesNoAnswer::NO.to_s }
      let(:has_savings) { YesNoAnswer::NO.to_s }

      it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
    end
  end

  context 'when the step is `manage_without_income`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :manage_without_income }

    before do
      allow(income).to receive_messages(
        income_above_threshold:,
        has_frozen_income_or_assets:,
        client_owns_property:,
        has_savings:
      )
    end

    context 'when full means assessment needs completing' do
      let(:income_above_threshold) { YesNoAnswer::YES.to_s }
      let(:has_frozen_income_or_assets) { YesNoAnswer::NO.to_s }
      let(:client_owns_property) { YesNoAnswer::NO.to_s }
      let(:has_savings) { YesNoAnswer::NO.to_s }

      it { is_expected.to have_destination('/steps/outgoings/housing_payment_type', :edit, id: crime_application) }
    end

    context 'when full means assessment does not need completing' do
      let(:income_above_threshold) { YesNoAnswer::NO.to_s }
      let(:has_frozen_income_or_assets) { YesNoAnswer::NO.to_s }
      let(:client_owns_property) { YesNoAnswer::NO.to_s }
      let(:has_savings) { YesNoAnswer::NO.to_s }

      it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
    end
  end
end

# rubocop:enable RSpec/MultipleMemoizedHelpers
