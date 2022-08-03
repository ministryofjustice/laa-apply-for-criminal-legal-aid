require 'rails_helper'

RSpec.describe Decisions::ContactDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  it_behaves_like 'a decision tree'

  context 'when the step is `home_address`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :home_address }

    it { is_expected.to have_destination('/home', :index) }
  end
end
