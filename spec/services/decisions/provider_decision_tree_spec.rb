require 'rails_helper'

RSpec.describe Decisions::ProviderDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  before do
    allow(
      form_object
    ).to receive(:crime_application).and_return(nil)
  end

  it_behaves_like 'a decision tree'

  context 'when the step is `confirm_office`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :confirm_office }

    context 'has correct next step' do
      it { is_expected.to have_destination('/home', :index, id: nil) }
    end
  end
end
