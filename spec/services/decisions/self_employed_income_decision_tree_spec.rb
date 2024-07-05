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
  let(:form_object) do
    double('FormObject', record: instance_double(Business, id: 'BUS123', ownership_type: ownership_type))
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
