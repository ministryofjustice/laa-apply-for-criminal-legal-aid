require 'rails_helper'

RSpec.describe Decisions::SelfEmployedIncomeDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      applicant: applicant,
      partner: partner,
      id: 'APP123'
    )
  end
  let(:expected_params) { { id: crime_application, business_id: form_object.record } }

  let(:applicant) { instance_double Applicant, to_param: 'client' }
  let(:partner) { instance_double Partner, to_param: 'partner' }

  let(:ownership_type) { OwnershipType::PARTNER }
  let(:business_type) { BusinessType::SELF_EMPLOYED }
  let(:form_object) do
    double('FormObject', record: instance_double(Business, id: 'BUS123', ownership_type: ownership_type,
                                                 business_type: business_type))
  end

  before do
    allow(form_object).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `business_type`' do
    let(:step_name) { :business_type }

    it { is_expected.to have_destination(:businesses, :edit, **expected_params) }
  end

  context 'when the step is `businesses`' do
    let(:step_name) { :businesses }

    it { is_expected.to have_destination(:business_nature, :edit, **expected_params) }
  end

  context 'when the step is `business_nature`' do
    let(:step_name) { :business_nature }

    it { is_expected.to have_destination(:business_start_date, :edit, **expected_params) }
  end

  context 'when the step is `business_start_date`' do
    let(:step_name) { :business_start_date }

    it { is_expected.to have_destination(:business_additional_owners, :edit, **expected_params) }
  end

  context 'when the step is `business_additional_owners`' do
    let(:step_name) { :business_additional_owners }

    it { is_expected.to have_destination(:business_employees, :edit, **expected_params) }
  end

  context 'when the step is `business_employees`' do
    let(:step_name) { :business_employees }

    it { is_expected.to have_destination(:business_financials, :edit, **expected_params) }
  end

  context 'when the step is `business_financials`' do
    let(:step_name) { :business_financials }

    context 'when the business type is self employed' do
      it { is_expected.to have_destination(:businesses_summary, :edit, **expected_params) }
    end

    context 'when the business type is director or shareholder' do
      let(:business_type) { BusinessType::DIRECTOR_OR_SHAREHOLDER.to_s }

      it { is_expected.to have_destination(:business_salary_or_remuneration, :edit, **expected_params) }
    end

    context 'when the business type is partnership' do
      let(:business_type) { BusinessType::PARTNERSHIP.to_s }

      it { is_expected.to have_destination(:business_percentage_profit_share, :edit, **expected_params) }
    end
  end

  context 'when the step is `business_salary_or_remuneration`' do
    let(:step_name) { :business_salary_or_remuneration }

    it { is_expected.to have_destination(:business_total_income_share_sales, :edit, **expected_params) }
  end

  context 'when the step is `business_total_income_share_sales`' do
    let(:step_name) { :business_total_income_share_sales }

    it { is_expected.to have_destination(:business_percentage_profit_share, :edit, **expected_params) }
  end

  context 'when the step is `business_percentage_profit_share`' do
    let(:step_name) { :business_percentage_profit_share }

    it { is_expected.to have_destination(:businesses_summary, :edit, **expected_params) }
  end

  context 'when the step is `businesses_summary`' do
    let(:step_name) { :businesses_summary }

    context 'when adding another business' do
      before { allow(form_object).to receive_messages(add_business: YesNoAnswer::YES) }

      it { is_expected.to have_destination(:business_type, :edit, id: crime_application) }
    end

    context 'when not adding another business' do
      before do
        allow(form_object).to receive_messages(add_business: YesNoAnswer::NO, subject: person)
      end

      context 'when applicant' do
        let(:person) { applicant }
        let(:destination) { 'steps/income/client/self_assessment_tax_bill' }

        it { is_expected.to have_destination(destination, :edit, id: crime_application) }
      end

      context 'when partner' do
        let(:person) { partner }
        let(:destination) { 'steps/income/partner/self_assessment_tax_bill' }

        it { is_expected.to have_destination(destination, :edit, id: crime_application) }
      end
    end
  end
end
