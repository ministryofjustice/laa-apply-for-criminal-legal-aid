require 'rails_helper'

RSpec.describe Decisions::SelfEmployedIncomeDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid'
    )
  end
  let(:ownership_type) { OwnershipType::PARTNER }
  let(:form_object) do
    double('FormObject', business: instance_double(Business, id: 'BUS123', ownership_type: ownership_type))
  end

  before do
    allow(form_object).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

  # context 'when the step is `business_type`' do
  #   let(:step_name) { :business_type }
  # end
end
