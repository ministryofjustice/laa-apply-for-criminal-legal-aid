require 'rails_helper'

RSpec.describe Decisions::IncomeDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
    )
  end

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

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
