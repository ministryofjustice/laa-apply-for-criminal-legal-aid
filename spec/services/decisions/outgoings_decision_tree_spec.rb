require 'rails_helper'

RSpec.describe Decisions::OutgoingsDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) do
    instance_double(
      CrimeApplication,
      id: 'uuid',
      outgoings: outgoings
    )
  end

  let(:outgoings) { instance_double(Outgoings) }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `outgoings_more_than_income`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :outgoings_more_than_income }

    context 'has correct next step' do
      it { is_expected.to have_destination('/home', :index, id: crime_application) }
    end
  end
end
