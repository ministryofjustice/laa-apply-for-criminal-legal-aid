require 'rails_helper'

RSpec.describe Decisions::OutgoingsDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
      outgoings: outgoings,
      kase: kase,
      partner_detail: partner_detail,
      partner: partner,
      non_means_tested?: false
    )
  end

  let(:outgoings) { instance_double(Outgoings) }
  let(:kase) { instance_double(Case, case_type:) }
  let(:case_type) { nil }
  let(:partner_detail) { instance_double(PartnerDetail, involvement_in_case:, conflict_of_interest:) }
  let(:partner) { instance_double(Partner) }
  let(:involvement_in_case) { nil }
  let(:conflict_of_interest) { nil }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `housing_payment_type`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :housing_payment_type }

    context 'with nothing somehow selected' do
      before do
        allow(
          form_object
        ).to receive(:housing_payment_type).and_return(nil)
      end

      it { is_expected.to have_destination(:council_tax, :edit, id: crime_application) }
    end

    context 'when the option selected is rent' do
      before do
        allow(
          form_object
        ).to receive(:housing_payment_type).and_return(HousingPaymentType::RENT)
      end

      context 'has correct next step' do
        it { is_expected.to have_destination(:rent, :edit, id: crime_application) }
      end
    end

    context 'when the rent form is completed' do
      let(:form_object) { double('FormObject') }
      let(:step_name) { :rent }

      context 'has correct next step' do
        it { is_expected.to have_destination(:council_tax, :edit, id: crime_application) }
      end
    end

    context 'when the option selected is mortgage' do
      before do
        allow(
          form_object
        ).to receive(:housing_payment_type).and_return(HousingPaymentType::MORTGAGE)
      end

      context 'has correct next step' do
        it { is_expected.to have_destination(:mortgage, :edit, id: crime_application) }
      end
    end

    context 'when the mortgage form is completed' do
      let(:form_object) { double('FormObject') }
      let(:step_name) { :mortgage }

      context 'has correct next step' do
        it { is_expected.to have_destination(:council_tax, :edit, id: crime_application) }
      end
    end

    context 'when the option selected is board_and_lodging' do
      before do
        allow(
          form_object
        ).to receive(:housing_payment_type).and_return(HousingPaymentType::BOARD_AND_LODGING)
      end

      context 'has correct next step' do
        it { is_expected.to have_destination(:board_and_lodging, :edit, id: crime_application) }
      end
    end

    context 'when the board_and_lodging form is completed' do
      let(:form_object) { double('FormObject') }
      let(:step_name) { :board_and_lodging }

      context 'has correct next step' do
        it { is_expected.to have_destination(:outgoings_payments, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `council_tax`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :council_tax }

    context 'has correct next step' do
      it { is_expected.to have_destination(:outgoings_payments, :edit, id: crime_application) }
    end
  end

  context 'when the step is `outgoings_payments`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :outgoings_payments }

    context 'has correct next step' do
      it { is_expected.to have_destination(:income_tax_rate, :edit, id: crime_application) }
    end
  end

  context 'when the step is `income_tax_rate`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :income_tax_rate }

    context 'and there is no relevant partner' do
      context 'when there is no partner' do
        let(:partner_detail) { nil }

        before do
          allow(crime_application).to receive(:partner)
        end

        it { is_expected.to have_destination(:outgoings_more_than_income, :edit, id: crime_application) }
      end

      context 'when partner is victim' do
        let(:involvement_in_case) { 'victim' }
        let(:conflict_of_interest) { nil }

        it { is_expected.to have_destination(:outgoings_more_than_income, :edit, id: crime_application) }
      end

      context 'when partner is codefendant with a conflict' do
        let(:involvement_in_case) { 'codefendant' }
        let(:conflict_of_interest) { 'yes' }

        it { is_expected.to have_destination(:outgoings_more_than_income, :edit, id: crime_application) }
      end
    end

    context 'and there is a relevant partner' do
      context 'has correct next step' do
        let(:involvement_in_case) { 'none' }

        it { is_expected.to have_destination(:partner_income_tax_rate, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `partner_income_tax_rate`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :partner_income_tax_rate }

    context 'has correct next step' do
      it { is_expected.to have_destination(:outgoings_more_than_income, :edit, id: crime_application) }
    end
  end

  context 'when the step is `outgoings_more_than_income`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :outgoings_more_than_income }

    context 'when case_type requires full capital assessment' do
      let(:case_type) { 'indictable' }

      context 'has correct next step' do
        it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
      end
    end

    context 'when case_type does not require full capital assessment' do
      let(:case_type) { 'summary_only' }

      context 'has correct next step' do
        it { is_expected.to have_destination(:answers, :edit, id: crime_application) }
      end
    end
  end

  context 'when the step is `answers`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :answers }

    context 'when case_type requires full capital assessment' do
      let(:case_type) { 'indictable' }

      context 'has correct next step' do
        it { is_expected.to have_destination('/steps/capital/property_type', :edit, id: crime_application) }
      end
    end

    context 'when case_type does not require full capital assessment' do
      let(:case_type) { 'summary_only' }

      context 'has correct next step' do
        it { is_expected.to have_destination('/steps/capital/trust_fund', :edit, id: crime_application) }
      end
    end
  end
end
