require 'rails_helper'

RSpec.describe Decisions::AddressDecisionTree do
  subject { described_class.new(form_object, as: step_name) }

  it_behaves_like 'a decision tree'

  context 'when the step is `lookup`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :lookup }

    it { is_expected.to have_destination(:details, :edit) }
  end

  context 'when the step is `details`' do
    let(:form_object) { double('FormObject') }
    let(:step_name) { :details }

    it { is_expected.to have_destination('/home', :index) }
  end
end
