require 'rails_helper'

RSpec.describe Decisions::IncomeDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
      applicant: applicant
    )
  end

  let(:applicant) { instance_double(Applicant, employment_status:) }
  let(:employment_status) { nil }

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
      let(:employment_status) { EmploymentStatus::EMPLOYED.to_s }

      it { is_expected.to have_destination(:employed_exit, :show, id: crime_application) }
    end

    context 'when status selected is not working' do
      let(:employment_status) { EmploymentStatus::NOT_WORKING.to_s }

      context 'when employment ended within 3 months' do
        before do
          allow(applicant).to receive(:ended_employment_within_three_months).and_return(YesNoAnswer::YES)
        end

        it { is_expected.to have_destination(:lost_job_in_custody, :edit, id: crime_application) }
      end

      context 'when employment has not ended within 3 months' do
        before do
          allow(applicant).to receive(:ended_employment_within_three_months).and_return(YesNoAnswer::NO)
        end

        it { is_expected.to have_destination('/home', :index, id: crime_application) }
      end
    end
  end

  context 'when the step is `lost_job_in_custody`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :lost_job_in_custody }

    context 'has correct next step' do
      it { is_expected.to have_destination(:manage_without_income, :edit, id: crime_application) }
    end
  end

  context 'when the step is `manage_without_income`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :manage_without_income }

    context 'has correct next step' do
      it { is_expected.to have_destination('/home', :index, id: crime_application) }
    end
  end
end
