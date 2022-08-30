require 'rails_helper'

RSpec.describe Decisions::CaseDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  let(:crime_application) { instance_double(CrimeApplication) }

  it_behaves_like 'a decision tree'

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(crime_application)
  end

  context 'when the step is `urn`' do
    let(:form_object) { double('FormObject', case: 'case') }
    let(:step_name) { :urn }

    context 'has correct next step' do
      let(:case) { '12AA3456789' }

      it { is_expected.to have_destination('/home', :index, id: crime_application) }
    end
  end
end
